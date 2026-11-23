// Starter SKSE plugin.
//
// What it does, so you can tell it is loaded:
//   - writes <PluginName>.log to CommonLibSSE-NG's log folder. That is usually
//     Documents\My Games\Skyrim Special Edition\SKSE, but CommonLibSSE-NG reads the folder name from game
//     memory, and on AE 1.6.1170 it was Documents\My Games\Skyrim.INI\SKSE (tested 2026-11-23).
//   - shows "<PluginName> <version> loaded" in the top-left corner when you start a new game or load a save,
//     once the loading screen has closed (a notification shown while it is still up is gone before you see it)
//
// Replace OnDataLoaded / OnGameStarted with your own code. Keep the logging: it is the first thing to read
// when something does not work.

#include <spdlog/sinks/basic_file_sink.h>

#include <atomic>
#include <exception>
#include <filesystem>
#include <format>
#include <memory>
#include <string>
#include <string_view>
#include <system_error>

namespace
{
    // Set when a game starts or a save finishes loading; cleared when the notification is requested.
    std::atomic_bool g_notifyAfterLoading{ false };
    bool             g_watcherRegistered{ false };

    [[nodiscard]] std::string PluginTitle()
    {
        const auto* plugin = SKSE::PluginDeclaration::GetSingleton();
        return std::format("{} {}", plugin->GetName(), plugin->GetVersion().string("."sv));
    }

    void InitializeLogging()
    {
        auto logDirectory = SKSE::log::log_directory();
        if (!logDirectory) {
            return;
        }

        std::error_code error;
        std::filesystem::create_directories(*logDirectory, error);
        if (error) {
            return;
        }

        try {
            const auto* plugin = SKSE::PluginDeclaration::GetSingleton();
            const auto logPath = *logDirectory / std::format("{}.log", plugin->GetName());
            auto sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(logPath.string(), true);
            auto logger = std::make_shared<spdlog::logger>(std::string(plugin->GetName()), std::move(sink));

            spdlog::set_default_logger(std::move(logger));
            spdlog::set_level(spdlog::level::info);
            spdlog::flush_on(spdlog::level::info);
        } catch (const std::exception&) {
            // No log file. The plugin still runs; there is nowhere to report this.
        }
    }

    void RequestLoadedNotification()
    {
        // DebugNotification returns nothing: this only proves the request was made, not that it was seen.
        RE::DebugNotification(std::format("{} loaded", PluginTitle()).c_str());
        SKSE::log::info("Notification requested");
    }

    // Waits for the loading screen to close. Observed on AE 1.6.1170: the close event arrives after the
    // load message, and the notification shows from this callback.
    class LoadingMenuWatcher final : public RE::BSTEventSink<RE::MenuOpenCloseEvent>
    {
    public:
        [[nodiscard]] static LoadingMenuWatcher* GetSingleton()
        {
            static LoadingMenuWatcher singleton;
            return &singleton;
        }

        RE::BSEventNotifyControl ProcessEvent(
            const RE::MenuOpenCloseEvent* a_event,
            RE::BSTEventSource<RE::MenuOpenCloseEvent>*) override
        {
            if (a_event && !a_event->opening &&
                std::string_view(a_event->menuName) == RE::LoadingMenu::MENU_NAME &&
                g_notifyAfterLoading.exchange(false)) {
                RequestLoadedNotification();
            }
            return RE::BSEventNotifyControl::kContinue;
        }

    private:
        LoadingMenuWatcher() = default;
    };

    // Registers the loading-screen watcher once the UI exists. Safe to call more than once.
    bool EnsureLoadingMenuWatcher()
    {
        if (g_watcherRegistered) {
            return true;
        }
        auto* ui = RE::UI::GetSingleton();
        if (!ui) {
            return false;
        }
        ui->AddEventSink<RE::MenuOpenCloseEvent>(LoadingMenuWatcher::GetSingleton());
        g_watcherRegistered = true;
        return true;
    }

    // All game data (every plugin's records) is loaded. No save is loaded yet.
    void OnDataLoaded()
    {
        SKSE::log::info("Game data loaded");
        if (!EnsureLoadingMenuWatcher()) {
            SKSE::log::warn("UI is not available yet; will try again when a game starts");
        }
    }

    // A new game was created (SKSE sends this before that game loads, so its loading screen is still to
    // come) or a save finished loading (its loading screen may still be up). Either way the notification
    // waits for the loading screen to close; if it is already closed after a save load, it shows now.
    // Do not touch the player or the world in the new-game case here: the game has not loaded yet.
    void OnGameStarted(bool a_newGame)
    {
        if (!EnsureLoadingMenuWatcher()) {
            g_notifyAfterLoading = false;
            SKSE::log::warn("UI is not available; no notification");
            return;
        }

        auto* ui = RE::UI::GetSingleton();
        if (a_newGame || (ui && ui->IsMenuOpen(RE::LoadingMenu::MENU_NAME))) {
            g_notifyAfterLoading = true;
            SKSE::log::info("{}; notification waits for the loading screen to close",
                a_newGame ? "New game" : "Game loaded");
        } else {
            g_notifyAfterLoading = false;
            SKSE::log::info("Game loaded");
            RequestLoadedNotification();
        }
    }

    void OnSKSEMessage(SKSE::MessagingInterface::Message* message)
    {
        if (!message) {
            return;
        }

        switch (message->type) {
        case SKSE::MessagingInterface::kDataLoaded:
            OnDataLoaded();
            break;
        case SKSE::MessagingInterface::kNewGame:
            OnGameStarted(true);
            break;
        case SKSE::MessagingInterface::kPostLoadGame:
            // For this message SKSE passes the load result itself in `data`: non-null means the save loaded.
            if (message->data) {
                OnGameStarted(false);
            } else {
                g_notifyAfterLoading = false;
                SKSE::log::warn("Loading the save failed; no notification");
            }
            break;
        default:
            break;
        }
    }
}

SKSEPluginLoad(const SKSE::LoadInterface* skse)
{
    SKSE::Init(skse);
    InitializeLogging();
    SKSE::log::info("{} starting", PluginTitle());

    auto* messaging = SKSE::GetMessagingInterface();
    if (!messaging || !messaging->RegisterListener(OnSKSEMessage)) {
        SKSE::log::error("Could not register for SKSE messages; the plugin will do nothing");
        return false;
    }

    return true;
}
