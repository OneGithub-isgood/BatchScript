@ECHO OFF
SETLOCAL EnableDelayedExpansion
TITLE Heroku Helper Version 1.1

ECHO Heroku Bot: You need to log in to your Heroku Account in another Command Prompt Window
ECHO Heroku Bot: After login successfully, close that Command Prompt Window and continue with this Command Prompt Window
ECHO Heroku Bot: Type N and press [Enter] if you see the following prompt: 'CTerminate batch job (Y/N)?' to continue...
Start /WAIT "" Heroku login

ECHO Heroku Bot: Initialize Git
Git init

TIMEOUT /T 2 /NOBREAK >NUL

ECHO Heroku Bot: Checking prerequisite file system.properties...
IF NOT EXIST system.properties (ECHO java.runtime.version=17) >>system.properties && TIMEOUT /T 5 /NOBREAK >NUL && ECHO Heroku Bot: Created system.properties file 
ECHO Heroku Bot: Checking prerequisite file system.properties...Done!

TIMEOUT /T 2 /NOBREAK >NUL

GOTO :checkRemoteRepositorySetting

:repositoryChoice
>>repositoryInformation.vbs ECHO WScript.Echo MsgBox( "Heroku remote repository setting not found", 0, "Heroku Bot's Information" )
>>repositoryInformation.vbs ECHO WScript.Echo MsgBox( "Do you want me to create automatically a random Git repository for you? Click No to specify your created Heroku App", 4, "Heroku Bot's Question" )
CSCRIPT.EXE /NoLogo repositoryInformation.vbs
IF ERRORLEVEL 7 (
	GOTO :manualHerokuRepositorySetup
) ELSE IF ERRORLEVEL 6 (
	GOTO :autoHerokuRepositorySetup
)

:manualHerokuRepositorySetup
>>repositoryQuestion.vbs ECHO WScript.Echo InputBox("Enter your Heroku Git URL in the textbox and click OK. Example: https://git.heroku.com/thawing-inlet-61413.git", "Heroku Bot's Question", "")
FOR /F "tokens=*" %%g in ('CSCRIPT.EXE //NoLogo repositoryQuestion.vbs') DO SET userHerokuApp=%%g
DEL repositoryQuestion.vbs
DEL repositoryInformation.vbs
ECHO Heroku Bot: Configuring your existing Heroku Git repository as a remote...
git remote add heroku %userHerokuApp%
ECHO Heroku Bot: Configuring your existing Heroku Git repository as a remote...Done!
GOTO :continueAfterConfigureRemoteRepository

:autoHerokuRepositorySetup
DEL repositoryInformation.vbs
ECHO Heroku Bot: Creating new Heroku App with empty Git repository...
FOR /F "tokens=2 delims=|" %%h in ('HEROKU create ^| FINDSTR /I /C:.git') DO SET herokuString=%%h
ECHO Heroku Bot: Creating new Heroku App with empty Git repository...Done!
SET herokuApp=%herokuString:~2%
git remote -v | Find "https://git.heroku.com/" >NUL
IF ERRORLEVEL 1 (
	GOTO :configureRemoteRepository
)
GOTO :continueAfterConfigureRemoteRepository

:configureRemoteRepository
ECHO Heroku Bot: Configuring Heroku new Git repository as a remote...
git remote add heroku %herokuApp%
ECHO Heroku Bot: Configuring Heroku new Git repository as a remote...Done!
GOTO :continueAfterConfigureRemoteRepository

:checkRemoteRepositorySetting
ECHO Heroku Bot: Checking Heroku remote repository setting...
git remote -v | Find "https://git.heroku.com/" >NUL
IF ERRORLEVEL 1 (
	GOTO :repositoryChoice
)
GOTO :continueAfterConfigureRemoteRepository

:continueAfterConfigureRemoteRepository
ECHO Heroku Bot: Checking Heroku remote repository setting...Done!

TIMEOUT /T 2 /NOBREAK >NUL

ECHO Heroku Bot: Staging all the untracked, changed files to ready for Commit...
git add .

TIMEOUT /T 2 /NOBREAK >NUL

ECHO Heroku Bot: Every commit need a Commit Message to identify the changes. You can type in anything such as version number or datetime.
>>commitMessageQuestion.vbs ECHO WScript.Echo InputBox( "Type your commit message in the textbox and click OK", "Heroku Bot's Question", "" )
FOR /F "tokens=*" %%i in ('CSCRIPT.EXE //NoLogo commitMessageQuestion.vbs') DO SET commitMessage=%%i
DEL commitMessageQuestion.vbs
TIMEOUT /T 2 /NOBREAK >NUL
ECHO Heroku Bot: Attempting to commit...
git commit -m "%commitMessage%"

TIMEOUT /T 2 /NOBREAK >NUL

ECHO Heroku Bot: Finally, now is the time to push the commit to your remote Heroku repository!
FOR /F "tokens=2 delims= " %%j in ('git branch') DO git push heroku %%j

ECHO Heroku Bot: Bye!
EXIT /B