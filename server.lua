-- Register system
-- Avtor: TheNormalnij

addEvent( 'onPlayerRegister' )

addEvent( 'onPlayerGuiLogin', true )
addEvent( 'onPlayerGuiRegister', true )

addEventHandler( 'onPlayerGuiRegister', root, function( login, passworld, isLogin )
	if not client or getElementType( client ) ~= 'player' then
		error( 'Bad client element in ' .. eventName, 2 )
	end
	if type( login ) ~= 'string' or #login == 0 then
		triggerClientEvent( client, 'onClientPlayerRegisterError', root, 1 )
		return
	end
	if type( passworld ) ~= 'string' or #passworld == 0 then
		triggerClientEvent( client, 'onClientPlayerRegisterError', root, 2 )
		return
	end
	if getAccount( login ) then
		triggerClientEvent( client, 'onClientPlayerRegisterError', root, 3 )
		return
	end
	local acc = addAccount( login, passworld )
	if acc then
		triggerClientEvent( client, 'onClientPlayerRegister', root, login )
		triggerEvent( 'onPlayerRegister', client, acc )
		if isLogin then
			logIn( client, login, passworld )
			triggerClientEvent( client, 'onClientPlayerLogin', root, login )
		end
	else
		triggerClientEvent( client, 'onClientPlayerRegisterError', root )
	end
end )

addEventHandler( 'onPlayerGuiLogin', root, function( login, passworld )
	if not client or getElementType( client ) ~= 'player' then
		error( 'Bad client element in ' .. eventName, 2 )
	end
	if type( login ) ~= 'string' or #login == 0 then
		triggerClientEvent( client, 'onClientPlayerLoginError', root, 1 )
		return
	end
	if type( passworld ) ~= 'string' or #passworld == 0 then
		triggerClientEvent( client, 'onClientPlayerLoginError', root, 2 )
		return
	end
	local acc = getAccount( login )
	if acc then
		if logIn( client, acc, passworld ) then
			triggerClientEvent( client, 'onClientPlayerLogin', root, login )
		else
			triggerClientEvent( client, 'onClientPlayerLoginError', root, 4 )
		end
	else
		triggerClientEvent( client, 'onClientPlayerLoginError', root, 3 )
	end
end )

addEventHandler( 'onPlayerLogin', root, function( _, acc )
	triggerClientEvent( source, 'onClientPlayerLogin', root, getAccountName( acc ) )
end )
