--Обязательная часть - поиск библиотек
package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
--Запуск модуля WXWidgets
local wx = require("wx")

--Функция по созданию окна
function createFrame(x, y, w, h, title, style, parent)

	--Модулятор стиля - спешиал фор вид окна
	if style == "full" then style = wx.wxDEFAULT_FRAME_STYLE  --Все модули
	elseif style == "nores" then style = wx.wxMINIMIZE_BOX + wx.wxCLOSE_BOX  --Только модуль закрыть и свернуть (без ресайза)
	elseif style == "resize" then style = wx.wxMINIMIZE_BOX + wx.wxCLOSE_BOX + wx.wxRESIZE_BORDER end --Только модуль закрыть и свернуть, но окно ресайзится

	--Создание окна
	local frame = wx.wxFrame(parent or wx.NULL, wx.wxID_ANY, tostring(title), wx.wxPoint(x, y) or wx.wxDefaultPosition, wx.wxSize(w, h) or wx.wxDefaultSize, style or wx.wxDEFAULT_FRAME_STYLE)
	frame:Show(true)

	frame:SetIcon(wx.wxIcon("./Lua/cicon.ico", 0))

	return frame
end

--Функция по установке иконки для окна (в топбар и таскбар)
function setAppIcon(element, iconDir)
	
	--Если элемент не является окном, то закрыть действие
	if getType(element) ~= "frame" then return false end

	element:SetIcon(wx.wxIcon(iconDir, 0))
end

--Получение типа обьекта
function getType(element)
	--Получаем текстовый идентификатор элемента
	local name = tostring(element)

	--переменная на вывод - тип элемента
	local typs = nil
	
	if name:find("wxButton") then --Если в идентификаторе будет найдено wxButton
		typs = "button" --То вернёт кнопку

	--Аналогично и для статического текста (или лейбла)
	elseif name:find("wxStaticText") then 
		typs = "label"

	--Для поля ввода текста
	elseif name:find("wxTextCtrl") then 
		typs = "edit"

	--Для окна
	elseif name:find("wxFrame") then 
		typs = "frame"

	else --В противном случае вернуть тип элемента
		typs = type(element) 
	end

	--Возврат аргумента
	return typs

end


--Отцентровка элемента
function centerElement(element) 
	return element:Centre() 
end

--Положение и размер
function setPosition(element, x, y) return element:SetPosition(wx.wxPoint(x, y)) end
function setSize(element, w, h) return element:SetSize(wx.wxSize(w, h)) end

--Установка текста элементу
function setText(element, text) 
	if getType(element) == "edit" then
		--Для поля ввода своя функция 
		return element:SetValue(tostring(text))
	else 
		--Для других - своя
		return element:SetLabel(tostring(text)) 
	end
end
--Получение текста от элемента
function getText(element) 
	--Аналогично функции выше
	if getType(element) == "edit" then
		--У эдитбокса своя 
		return element:GetValue()
	else 
		--Для других своя
		return element:GetLabel() 
	end
end

--Создание кнопки
function createButton(x, y, w, h, title, style, parent)

	--Если нет родительского элемента, то не запускать кнопку
	if not parent then return false end

	--Создать кнопку
	local button = wx.wxButton(parent, wx.wxID_ANY, tostring(title), wx.wxPoint(x, y) or wx.wxDefaultPosition, wx.wxSize(w, h) or wx.wxDefaultSize, style or wx.wxBU_EXACTFIT)
	
	--Вернуть кнопку
	return button
end

--Создание текстового поля
function createEdit(x, y, w, h, text, style, parent)

	--Если нет родительского элемента, то не создавать поле
	if not parent then return false end

	--Стили эдитбокса
	--Если нажимать таб для переключения между различными элементами и энтер для применения (однострочный)
	if style == "tab" then 
		style = wx.wxTE_PROCESS_TAB + wx.wxTE_PROCESS_ENTER

	--Если однострочный только для чтения
	elseif style == "read" then 
		style = wx.wxTE_READONLY

	--Если многострочный просто
	elseif style == "mline" then 
		style = wx.wxTE_MULTILINE

	--Если многострочный только для чтения
	elseif style == "mread" then 
		style = wx.wxTE_MULTILINE + wx.wxTE_READONLY

	--Если пароль с применением (enter) и с переходом на другие элементы (таб)
	elseif style == "pass" then 
		style = wx.wxTE_PASSWORD + wx.wxTE_PROCESS_ENTER + wx.wxTE_PROCESS_TAB

	--Если пароль только для чтения
	elseif style == "readpass" then 
		style = wx.wxTE_PASSWORD + wx.wxTE_READONLY 

	--По умолчанию - обычный однострочный эдитбокс без дополнительных свистоперделок
	elseif style == "default" then 
		style = 0 
	end

	--Создание
	local edit = wx.wxTextCtrl(parent, wx.wxID_ANY, tostring(text), wx.wxPoint(x, y) or wx.wxDefaultPosition, wx.wxSize(w, h) or wx.wxDefaultSize, style or 0)

	--Вернуть
	return edit
end

--Создание обычного текста на экране
function createLabel(x, y, w, h, text, style, parent)

	--Если нет родительского элемента, то не создавать лейбл
	if not parent then return false end

	--Стиль текста, оф корс
	--Почему то не работают другие положения, кроме LEFT
	if style == "aleft" then 
		style = wx.wxALIGN_LEFT

	elseif style == "aright" then 
		style = wx.wxALIGN_RIGHT

	elseif style == "acent" then 
		style = wx.wxALIGN_CENTRE_HORIZONTAL
	end

	--Создание
	local label = wx.wxStaticText(parent, wx.wxID_ANY, tostring(text), wx.wxPoint(x, y) or wx.wxDefaultPosition, wx.wxSize(w, h) or wx.wxDefaultSize, style or 0)

	return label
end

--Функция по вызову события
function executeEvent(element, name, funct)

	--Если нет элемента, то не делать ничего
	if not element then return false end
	
	--Если элемент кнопка - чекаем на названия
	if getType(element) == "button" then
		--Если событие onClick
		if name == "onClick" then
			--То название соответствует событию нажатия кнопки 
			name = wx.wxEVT_COMMAND_BUTTON_CLICKED 
		end
	end

	--Создаём событие
	element:Connect(wx.wxID_ANY, name, funct) --Функция дефайнится с аргументом event

end

--Функция, которая должна стоять в конце каждого форм-файла.
function runApplication() return wx.wxGetApp():MainLoop() end


--Экземплы/тесты
--local f = createFrame(40, 40, 200, 210, "test", "full")
--centerElement(f)
--local b = createButton(10, 10, 180, 50, "Button", _, f)
--local e = createEdit(10, 70, 180, 60, "text1454", "default", f)
--local l = createLabel(10, 140, 180, 20, "Testing text", "aleft", f)

--executeEvent(b, "onClick", function(event)
--	setText(l, getText(e))
--end)

--wx.wxGetApp():MainLoop()
