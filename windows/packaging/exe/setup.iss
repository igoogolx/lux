[Setup]
AppId={{APP_ID}}
AppVersion={{APP_VERSION}}
AppName={{DISPLAY_NAME}}
AppPublisher={{PUBLISHER_NAME}}
AppPublisherURL={{PUBLISHER_URL}}
AppSupportURL={{PUBLISHER_URL}}
AppUpdatesURL={{PUBLISHER_URL}}
DefaultDirName={{INSTALL_DIR_NAME}}
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename={{OUTPUT_BASE_FILENAME}}
Compression=lzma
SolidCompression=yes
SetupIconFile={{SETUP_ICON_FILE}}
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableFinishedPage=yes
AppMutex=lux.app.mutex,Global\lux.app.mutex

[Languages]
{% for locale in LOCALES %}
{% if locale == 'en' %}Name: "english"; MessagesFile: "compiler:Default.isl"{% endif %}
{% if locale == 'hy' %}Name: "armenian"; MessagesFile: "compiler:Languages\\Armenian.isl"{% endif %}
{% if locale == 'bg' %}Name: "bulgarian"; MessagesFile: "compiler:Languages\\Bulgarian.isl"{% endif %}
{% if locale == 'ca' %}Name: "catalan"; MessagesFile: "compiler:Languages\\Catalan.isl"{% endif %}
{% if locale == 'zh' %}Name: "chinesesimplified"; MessagesFile: "..\\..\\windows\\packaging\\exe\\ChineseSimplified.isl"{% endif %}
{% if locale == 'co' %}Name: "corsican"; MessagesFile: "compiler:Languages\\Corsican.isl"{% endif %}
{% if locale == 'cs' %}Name: "czech"; MessagesFile: "compiler:Languages\\Czech.isl"{% endif %}
{% if locale == 'da' %}Name: "danish"; MessagesFile: "compiler:Languages\\Danish.isl"{% endif %}
{% if locale == 'nl' %}Name: "dutch"; MessagesFile: "compiler:Languages\\Dutch.isl"{% endif %}
{% if locale == 'fi' %}Name: "finnish"; MessagesFile: "compiler:Languages\\Finnish.isl"{% endif %}
{% if locale == 'fr' %}Name: "french"; MessagesFile: "compiler:Languages\\French.isl"{% endif %}
{% if locale == 'de' %}Name: "german"; MessagesFile: "compiler:Languages\\German.isl"{% endif %}
{% if locale == 'he' %}Name: "hebrew"; MessagesFile: "compiler:Languages\\Hebrew.isl"{% endif %}
{% if locale == 'is' %}Name: "icelandic"; MessagesFile: "compiler:Languages\\Icelandic.isl"{% endif %}
{% if locale == 'it' %}Name: "italian"; MessagesFile: "compiler:Languages\\Italian.isl"{% endif %}
{% if locale == 'ja' %}Name: "japanese"; MessagesFile: "compiler:Languages\\Japanese.isl"{% endif %}
{% if locale == 'no' %}Name: "norwegian"; MessagesFile: "compiler:Languages\\Norwegian.isl"{% endif %}
{% if locale == 'pl' %}Name: "polish"; MessagesFile: "compiler:Languages\\Polish.isl"{% endif %}
{% if locale == 'pt' %}Name: "portuguese"; MessagesFile: "compiler:Languages\\Portuguese.isl"{% endif %}
{% if locale == 'ru' %}Name: "russian"; MessagesFile: "compiler:Languages\\Russian.isl"{% endif %}
{% if locale == 'sk' %}Name: "slovak"; MessagesFile: "compiler:Languages\\Slovak.isl"{% endif %}
{% if locale == 'sl' %}Name: "slovenian"; MessagesFile: "compiler:Languages\\Slovenian.isl"{% endif %}
{% if locale == 'es' %}Name: "spanish"; MessagesFile: "compiler:Languages\\Spanish.isl"{% endif %}
{% if locale == 'tr' %}Name: "turkish"; MessagesFile: "compiler:Languages\\Turkish.isl"{% endif %}
{% if locale == 'uk' %}Name: "ukrainian"; MessagesFile: "compiler:Languages\\Ukrainian.isl"{% endif %}
{% endfor %}

[Files]

Source: "C:\temp\dll\*"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist

[Run]
Filename: {app}\lux.exe; Flags: shellexec skipifsilent nowait; Tasks: StartAfterInstall

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: {% if CREATE_DESKTOP_ICON != true %}unchecked{% else %}checkedonce{% endif %}
Name: StartAfterInstall; Description: Run application after install

[Files]
Source: "{{SOURCE_DIR}}\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"
Name: "{autodesktop}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"; Tasks: desktopicon

[UninstallDelete]
Type: filesandordirs; Name: "{localappdata}\..\Roaming\com.github.igoogolx\lux"
; NOTE: delete any file cautiously

[Code]

// ------------------------------------------------------------
// Configuration
// ------------------------------------------------------------
const
  AppDisplayName       = '{#SetupSetting("AppName")}';             //  App name shown in the closing message
  AppClassName         = '{#SetupSetting("AppName")}';             //  Class name of the app's main window
  AppMutexName         = '{#SetupSetting("AppMutex")}'; // Taken from [Setup] AppMutex at compile time (ISPP); used to detect whether the app is running / has exited
  WM_QUERYENDSESSION   = $0011;          // Asks the app whether it agrees to end the session
  CloseTimeoutMs       = 5000;           // Timeout (ms) waiting for the app window to disappear; adjust as needed
  ProcessExitTimeoutMs = 3000;           // Timeout (ms) waiting for the process to exit after the window is gone; adjust as needed
  ClosePollStepMs      = 200;            // Polling interval (ms)

// ------------------------------------------------------------
// Returns the "Closing xxx" message for the current setup language
// (Chinese / English). ActiveLanguage returns the internal name defined
// in the [Languages] section; anything other than Simplified Chinese
// falls back to English.
// ------------------------------------------------------------
function ClosingAppMessage(): String;
begin
  if ActiveLanguage() = 'chinesesimplified' then
    Result := '正在关闭 ' + AppDisplayName
  else
    Result := 'Closing ' + AppDisplayName;
end;

// ------------------------------------------------------------
// Fills in and shows the "Closing" popup created by CreateCustomForm.
// It is shown with Show (modeless): unlike MsgBox, Show does not block,
// so execution continues and the code can close the popup by itself
// once the app has exited.
// FlipAndCenterIfNeeded is not called on purpose: without it the form is still
// centered automatically (on the screen), and there is no WizardForm to center
// on at this point (InitializeSetup / uninstall).
// ------------------------------------------------------------
procedure ShowClosingForm(const Form: TSetupForm);
var
  Lbl: TNewStaticText;
begin
  Form.Caption := AppDisplayName;
  Form.BorderIcons := []; // No title bar close button: the popup closes automatically, no user action needed

  Lbl := TNewStaticText.Create(Form);
  Lbl.Parent := Form;
  Lbl.AutoSize := True;
  Lbl.Caption := ClosingAppMessage();
  // Center the text horizontally and vertically
  Lbl.Left := (Form.ClientWidth - Lbl.Width) div 2;
  Lbl.Top := (Form.ClientHeight - Lbl.Height) div 2;

  Form.Show;

  // No message loop runs during the wait loops below, so the window won't
  // repaint itself. Force one paint here, otherwise the popup may appear blank.
  Form.Refresh;
  Lbl.Refresh;
end;

// ------------------------------------------------------------
// Graceful close: find the main window by class name
// 1. Show the "Closing" popup
// 2. Send WM_QUERYENDSESSION to ask whether the app agrees to end the session
// 3. Poll until the window disappears, up to CloseTimeoutMs; move on as soon as it's gone
// 4. Once the window is gone, use the mutex to check whether the process
//    has exited, up to ProcessExitTimeoutMs
// 5. Close the popup automatically when done (on success or timeout)
// ------------------------------------------------------------
procedure GracefulCloseAppByClass(const ClassName: string);
var
  Wnd: HWND;
  Elapsed: Integer;
  ClosingForm: TSetupForm;
begin
  Wnd := FindWindowByClassName(ClassName);
  if Wnd = 0 then
    Exit; // Window not found, return right away

  // Since Inno Setup 6.6.0 the client size must be passed at creation (read-only afterwards).
  // Last two parameters True: keep a fixed size, don't grow with WizardSizePercent.
  // "try" follows the creation immediately (as in the official CodeClasses.iss example),
  // so the form is freed even if something fails while it is being built or shown.
  ClosingForm := CreateCustomForm(ScaleX(320), ScaleY(90), True, True);
  try
    ShowClosingForm(ClosingForm);

    // SendMessage blocks until the target window procedure has processed the message
    SendMessage(Wnd, WM_QUERYENDSESSION, 0, 0);

    // Wait for the window to disappear
    Elapsed := 0;
    while (Elapsed < CloseTimeoutMs) and (FindWindowByClassName(ClassName) <> 0) do
    begin
      Sleep(ClosePollStepMs);
      Elapsed := Elapsed + ClosePollStepMs;
    end;

    // Once the window is gone (closed successfully), make sure the process has really exited:
    // after its window is destroyed, the process may still be cleaning up and holding files.
    // When a process exits, the system closes all handles it holds and the mutex goes away,
    // so once the mutex no longer exists, the process can be considered exited.
    if FindWindowByClassName(ClassName) = 0 then
    begin
      Elapsed := 0;
      while (Elapsed < ProcessExitTimeoutMs) and CheckForMutexes(AppMutexName) do
      begin
        Sleep(ClosePollStepMs);
        Elapsed := Elapsed + ClosePollStepMs;
      end;
    end;
  finally
    // Close the popup whether the app closed or the wait timed out, so it never stays on screen
    ClosingForm.Free;
  end;
end;

// ------------------------------------------------------------
// Setup hook: first use CheckForMutexes to check whether the app is running
// ------------------------------------------------------------
function InitializeSetup(): Boolean;
begin
  Result := True;
  if CheckForMutexes(AppMutexName) then
    GracefulCloseAppByClass(AppClassName);
end;

// ------------------------------------------------------------
// Uninstall hook: same mutex check first
// ------------------------------------------------------------
function InitializeUninstall(): Boolean;
begin
  Result := True;
  if CheckForMutexes(AppMutexName) then
    GracefulCloseAppByClass(AppClassName);
end;