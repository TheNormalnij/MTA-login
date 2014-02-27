-- Login system
-- Avtor: TheNormalnij

local LOGIN_ERRORS = {
	[1] = 'Bad login';
	[2] = 'Bad passworld';
	[3] = 'Wrong login';
	[4] = 'Wrong passworld';
}

local REGISTER_ERRORS = {
	[1] = 'Bad login';
	[2] = 'Bad passworld';
	[3] = 'Account exists';
}

addEvent( 'onClientPlayerRegisterError', true )
addEvent( 'onClientPlayerLoginError', true )

addEvent( 'onClientPlayerLogin', true )
addEvent( 'onClientPlayerRegister', true )
--

function buildGui( )
	local sX, sY = guiGetScreenSize()
	local w, h = 250, 225
	window = guiCreateWindow( ( sX - w ) / 2, ( sY - h ) / 2, w, h, 'Login system by TheNormalnij', false )

	guiWindowSetSizable ( window, false )

	local tabPanel = guiCreateTabPanel ( 0, 0.1 * h, w, h * 0.8, false, window ) 
	local tabLogin = guiCreateTab( "Login", tabPanel )
	local tabRegister = guiCreateTab( "Register", tabPanel )

	local labError = guiCreateLabel( 10, h - 25, w - 25, 20, '', false, window )
	guiLabelSetHorizontalAlign( labError, 'center' )

	local function registerErrorHandler( errorID )
		guiSetText( labError, REGISTER_ERRORS[errorID] or 'Unregister error' )
		guiLabelSetColor( labError, 200, 0, 0 )
	end

	local function loginErrorHandler( errorID )
		guiSetText( labError, LOGIN_ERRORS[errorID] or 'Unregister error' )
		guiLabelSetColor( labError, 200, 0, 0 )
	end
	addEventHandler( 'onClientPlayerRegisterError', root, registerErrorHandler )
	addEventHandler( 'onClientPlayerLoginError', root, loginErrorHandler )

	local function onCancelClick()
		showGui( false )
	end

	do -- login tab
		guiCreateLabel( 15, 10, 80, 20, 'Username', false, tabLogin )
		local eLogin = guiCreateEdit( 100, 10, 100, 20, '' , false, tabLogin )
		guiCreateLabel( 15, 45, 80, 20, 'Passworld', false, tabLogin )
		local ePassworld = guiCreateEdit( 100, 45, 100, 20, '' , false, tabLogin )

		local chekAvtologin = guiCreateCheckBox( 20, 75, w * 0.75, 20, 'Use avtologin on this pc...', true, false, tabLogin )

		local bLogin = guiCreateButton( 20, 110, 80, 30, 'Login', false, tabLogin )
		local bCancel = guiCreateButton( 125, 110, 80, 30, 'Cancel', false, tabLogin )

		local function onLoginClick()
			local login = guiGetText( eLogin )
			local passworld = guiGetText( ePassworld )
			if #login == 0 then
				guiSetText( labError, 'Enter login' )
				guiLabelSetColor( labError, 200, 0, 0 )
				return
			end
			if #passworld == 0 then
				guiSetText( labError, 'Enter passworld' )
				guiLabelSetColor( labError, 200, 0, 0 )
				return
			end
			passworld = md5( passworld ):sub( 0, 16 )
			if guiCheckBoxGetSelected( chekAvtologin ) then
				local avtologin = fileCreate( 'Avtologin.lnk' )
				fileWrite( avtologin, passworld .. login )
			end
			guiSetText( labError, 'Login...' )
			guiLabelSetColor( labError, 0, 200, 0 )
			triggerServerEvent( 'onPlayerGuiLogin', root, login, passworld )
		end
		addEventHandler( 'onClientGUIClick', bLogin, onLoginClick, false )

		addEventHandler( 'onClientGUIClick', bCancel, onCancelClick, false )
	end
	do -- register tab
		guiCreateLabel( 15, 10, 80, 20, 'Username', false, tabRegister )
		local eLogin = guiCreateEdit( 100, 10, 100, 20, '' , false, tabRegister )
		guiCreateLabel( 15, 45, 80, 20, 'Passworld', false, tabRegister )
		local ePassworld = guiCreateEdit( 100, 45, 100, 20, '' , false, tabRegister )
		guiCreateLabel( 15, 80, 80, 20, 'Conflim', false, tabRegister )
		local ePassworldConflim = guiCreateEdit( 100, 80, 100, 20, '' , false, tabRegister )
		local bRegister = guiCreateButton( 20, 110, 80, 30, 'Register', false, tabRegister )
		local bCancel = guiCreateButton( 125, 110, 80, 30, 'Cancel', false, tabRegister )

		local function onRegisterClick()
			local login = guiGetText( eLogin )
			local passworld = guiGetText( ePassworld )
			local passworld2 = guiGetText( ePassworldConflim )
			if #login == 0 then
				guiSetText( labError, 'Enter login' )
				guiLabelSetColor( labError, 200, 0, 0 )
				return
			end
			if #passworld == 0 then
				guiSetText( labError, 'Enter passworld' )
				guiLabelSetColor( labError, 200, 0, 0 )
				return
			end
			if passworld ~= passworld2 then
				guiSetText( labError, 'Passwords do not match' )
				guiLabelSetColor( labError, 200, 0, 0 )
				return
			end
			guiSetText( labError, 'Register...' )
			guiLabelSetColor( labError, 0, 200, 0 )
			passworld = md5( passworld ):sub( 0, 16 )
			triggerServerEvent( 'onPlayerGuiRegister', root, login, passworld, true )
		end
		addEventHandler( 'onClientGUIClick', bRegister, onRegisterClick, false )

		addEventHandler( 'onClientGUIClick', bCancel, onCancelClick, false )
	end
end

function showGui( state )
	if window and isElement( window ) then
		showCursor( state )
		guiSetVisible( window, state )
	elseif state == true then
		buildGui()
		showCursor( true )
	end
end

addEventHandler( 'onClientPlayerLogin', root, function()
	showGui( false )
end )

addEventHandler( 'onClientResourceStart', resourceRoot, function( )
	local avtologin = fileOpen( 'Avtologin.lnk', true )
	if avtologin then
		local size = fileGetSize( avtologin )
		if size > 17 then
			local key = fileRead( avtologin, 16 )
			local login = fileRead( avtologin, size - 16 )
			triggerServerEvent( 'onPlayerGuiLogin', root, login, key )
			local errorHandler
			errorHandler = function( )
				showGui( true )
				removeEventHandler( 'onClientPlayerLoginError', root, errorHandler )
				errorHandler = nil
			end
			addEventHandler( 'onClientPlayerLoginError', root, errorHandler )
		else
			fileClose( avtologin )
			fileDelete( 'Avtologin.lnk' ) -- good bye
			showGui( true )
		end
	else
		showGui( true )
	end
end )
