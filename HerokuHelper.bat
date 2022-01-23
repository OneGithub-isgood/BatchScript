@ECHO OFF
SETLOCAL EnableDelayedExpansion
TITLE Heroku Helper Version 1.0

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

ECHO Heroku Bot: Checking Heroku repositories setting...
git remote -v | Find "https://git.heroku.com/" >NUL
IF ERRORLEVEL 1 (
	ECHO Heroku Bot: Heroku repositories setting not found. Creating new Heroku repositories...
	FOR /F "tokens=2 delims=|" %%g in ('HEROKU create ^| FINDSTR /I /C:.git') DO SET herokuString=%%g
	ECHO Heroku Bot: Heroku repositories setting not found. Creating new Heroku repositories...Done!
	SET herokuGit=%herokuString:~2%
	ECHO Heroku Bot: Configuring Heroku repositories setting with new Heroku repositories...
	git remote add heroku "herokuGit"
	ECHO Heroku Bot: Configuring Heroku repositories setting with new Heroku repositories...Done!
	)
ECHO Heroku Bot: Checking Heroku repositories setting...Done!

TIMEOUT /T 2 /NOBREAK >NUL

ECHO Heroku Bot: Staging all the untracked, changed files to ready for Commit...
git add .

TIMEOUT /T 2 /NOBREAK >NUL

ECHO Heroku Bot: Every commit need a Commit Message to identify the changes. You can type in anything such as version number or datetime.
>>usermessage.vbs ECHO WScript.Echo InputBox( "Type your commit message in the textbox and click OK", "Heroku Bot's Message", "" )
FOR /F "tokens=*" %%h in ('CSCRIPT.EXE //NoLogo usermessage.vbs') DO SET commitMessage=%%h
DEL usermessage.vbs
TIMEOUT /T 2 /NOBREAK >NUL
ECHO Heroku Bot: Attempting to commit...
git commit -m "%commitMessage%"

TIMEOUT /T 2 /NOBREAK >NUL

ECHO Heroku Bot: Finally, now is the time to push the commit to Heroku repositories!
FOR /F "tokens=2 delims= " %%h in ('git branch') DO git push heroku %%h

ECHO Heroku Bot: Bye!
EXIT /B