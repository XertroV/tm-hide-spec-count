void Main(){
    startnew(WatchForEnterServerMap);
}

void Unload() {
    FindPage(GetApp().Network.ClientManiaAppPlayground, true);
}
void OnDestroyed() { Unload(); }
void OnDisabled() { Unload(); }


[Setting hidden]
bool g_Enabled = true;

void RenderMenu() {
    if (UI::MenuItem("\\$9ae" + Icons::EyeSlash + "\\$z Hide Spectators Count", "", g_Enabled)) {
        g_Enabled = !g_Enabled;
        if (g_Enabled) {
            FindPage(GetApp().Network.ClientManiaAppPlayground, false);
        } else {
            FindPage(GetApp().Network.ClientManiaAppPlayground, true);
        }
    }
}

string lastMap;
void WatchForEnterServerMap() {
    auto app = GetApp();
    while (true) {
        yield();
        while (!g_Enabled) yield();
        if (app.Network is null || app.Network.ClientManiaAppPlayground is null) {
            OnLeftServer();
            continue;
        }
        if (app.Network.ClientManiaAppPlayground.UILayers.Length < 5) continue;
        while (app.RootMap is null) yield();
        if (app.RootMap.EdChallengeId != lastMap) {
            OnLeftServer();
            OnEnterServer();
        }
    }
}

void OnLeftServer() {
    // reset any state here
    lastMap = "";
}

const string PageUID = "Lib_UI2:ViewersCount";

void OnEnterServer() {
    auto app = GetApp();
    lastMap = app.RootMap.EdChallengeId;
    auto cmap = app.Network.ClientManiaAppPlayground;
    while ((@cmap = app.Network.ClientManiaAppPlayground) !is null) {
        if (FindPage(cmap, false)) break;
        sleep(100);
    }
}

bool FindPage(CGameManiaAppPlayground@ cmap, bool setVisible) {
    if (cmap is null) return false;
    bool foundPage = false;
    for (int i = cmap.UILayers.Length - 1; i >= 0; i--) {
        auto layer = cmap.UILayers[i];
        bool isNormal = layer.Type == CGameUILayer::EUILayerType::Normal;
        if (isNormal && layer.ManialinkPage.SubStr(0, 59).StartsWith("\n<manialink version=\"3\" name=\"Lib_UI2:ViewersCount\">")) {
            // found page
            foundPage = true;
            layer.IsVisible = setVisible;
            break;
        }
    }
    return foundPage;
}
