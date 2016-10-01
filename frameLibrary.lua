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
	local id = wx.wxID_ANY
	local frame = wx.wxFrame(parent or wx.NULL, id, tostring(title), wx.wxPoint(x, y) or wx.wxDefaultPosition, wx.wxSize(w, h) or wx.wxDefaultSize, style or wx.wxDEFAULT_FRAME_STYLE)
	frame:Show(true)

	return frame, id
end

--Функция по установке иконки для окна (в топбар и таскбар)
function setAppIcon(element, iconDir)
	
	--Если элемент не является окном, то закрыть действие
	if getType(element) ~= "frame" then 
		print("Error with FRAME ICON: element is not frame")
		return false 
	end

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
	if not parent then 
		print("Error with CREATING BUTTON: needs parent")
		return false 
	end

	--Создать кнопку
	local id = wx.wxID_ANY
	local button = wx.wxButton(parent, id, tostring(title), wx.wxPoint(x, y) or wx.wxDefaultPosition, wx.wxSize(w, h) or wx.wxDefaultSize, style or wx.wxBU_EXACTFIT)
	
	--Вернуть кнопку
	return button, id
end

--Создание текстового поля
function createEdit(x, y, w, h, text, style, parent)

	--Если нет родительского элемента, то не создавать поле
	if not parent then 
		print("Error with CREATING EDIT: needs parent")
		return false 
	end

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
	local id = wx.wxID_ANY
	local edit = wx.wxTextCtrl(parent, id, tostring(text), wx.wxPoint(x, y) or wx.wxDefaultPosition, wx.wxSize(w, h) or wx.wxDefaultSize, style or 0)

	--Вернуть
	return edit, id
end

--Создание обычного текста на экране
function createLabel(x, y, w, h, text, style, parent)

	--Если нет родительского элемента, то не создавать лейбл
	if not parent then 
		print("Error with CREATING LABEL: needs parent")
		return false 
	end

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
	local id = wx.wxID_ANY
	local label = wx.wxStaticText(parent, id, tostring(text), wx.wxPoint(x, y) or wx.wxDefaultPosition, wx.wxSize(w, h) or wx.wxDefaultSize, style or 0)

	return label, id
end

function getEventID(element, name, key)

	--Если элемент кнопка - чекаем на названия
	if getType(element) == "button" then
		--Если событие onClick
		if name == "onClick" then
			--То название соответствует событию нажатия кнопки 
			name = wx.wxEVT_COMMAND_BUTTON_CLICKED 
		end

	--Если элемент окно
	elseif getType(element) == "frame" then
		--Если событие onMove
		if name == "onMove" then
			--То назначаем функцию перемещения
			name = wx.wxEVT_MOVE
		
		--Если событие onResize 
		elseif name == "onResize" then
			--То назначаем ресайз
			name = wx.wxEVT_SIZE

		--Если закрытие
		elseif name == "onClose" then
			name = wx.wxEVT_CLOSE_WINDOW

		--При активировании элемента (переносе окна вперёд)
		elseif name == "onActivate" then
			name = wx.wxEVT_ACTIVATE

		--Если событие нажатия на клавиатуре
		elseif name == "onKey" then
			name = wx.wxEVT_CHAR_HOOK

		end
	end
	
	--События для всех элементов
	if getType(element) ~= type(element) then
		--Событие по зажатию
		if name == "onMouseDown" then
			--если аргумента ключа нет, он становится левым
			if not key then key = "left" end

			--Для каждого ключа своё событие
			if key == "left" then name = wx.wxEVT_LEFT_DOWN
			elseif key == "right" then name = wx.wxEVT_RIGHT_DOWN
			elseif key == "middle" then name = wx.wxEVT_MIDDLE_DOWN
			end

		--Событие при отведении
		elseif name == "onMouseUp" then
			if not key then key = "left" end

			if key == "left" then name = wx.wxEVT_LEFT_UP
			elseif key == "right" then name = wx.wxEVT_RIGHT_UP
			elseif key == "middle" then name = wx.wxEVT_MIDDLE_UP
			end

		--Событие при двойном нажатии
		elseif name == "onMouseDoubleClick" then
			if not key then key = "left" end

			if key == "left" then name = wx.wxEVT_LEFT_DCLICK
			elseif key == "right" then name = wx.wxEVT_RIGHT_DCLICK
			elseif key == "middle" then name = wx.wxEVT_MIDDLE_DCLICK
			end

		--Событие при наведении
		elseif name == "onMouseEnter" then
			name = wx.wxEVT_ENTER_WINDOW

		--Событие при отведении
		elseif name == "onMouseLeave" then
			name = wx.wxEVT_LEAVE_WINDOW

		--Колесо мыши
		elseif name == "onWheel" then
			if not key then name = wx.wxEVT_MOUSEWHEEL end

			--Чот эти события не работают:
			if key == "up" then name = wx.wxEVT_SCROLL_LINEUP
			elseif key == "down" then name = wx.wxEVT_SCROLL_LINEDOWN
			end

		--При показе элемента
		elseif name == "onShows" then
			name = wx.wxEVT_SHOW 

		end
	end

	return name
end

--Функция по созданию события
local funTab = {} --Таблица, в которую сохраняются функции по событиям
function addEvent(element, name, funct, key)

	--Если нет элемента, то не делать ничего
	if not element then 
		print("Error with EVENT HANDLING: needs element")
		return false 
	end
	
	--Получаем название события
	name = getEventID(element, name, key)

	if not tonumber(name) then 
		print("Error with EVENT HANDLING: no event for \""..tostring(name).."\"")
		return false 
	end

	--Создаём событие
	local ret = element:Connect(wx.wxID_ANY, name, funct) --Функция дефайнится с аргументом event
	
	--Сохраняем функцию для повтора события
	--Если таблицы не существует, то создать её
	if funTab[element] == nil then funTab[element] = {} end
	--Сохранить элементу по имени - функцию
	funTab[element][name] = funct
end

--Функция по вызову созданного события
function executeEvent(element, name, key)

	--Получаем ID события по имени
	local oldName = name --Сохраним для ошибки
	name = getEventID(element, name, key)

	--Если в таблице функций нет такого элемента
	if not funTab[element] then
		--То прервать функцию
		print("Error with EXECUTING EVENT: events for this element not handled")
		return false
	end

	--Если в таблице есть элемент, но нет ID события на него
	if not funTab[element][name] then
		--То прервать функцию
		print("Error with EXECUTING EVENT: event \""..oldName.."\" not handled")
		return false
	end

	--исполняем функцию события
	funTab[element][name]()
end


--Таблица символов
local tableChars = {
	[wx.WXK_BACK] = "backspace",
	
	[wx.WXK_TAB] = "tab",

	[wx.WXK_RETURN] = "enter",
	[wx.WXK_ESCAPE] = "esc",
	[wx.WXK_SPACE] = "space",

	[wx.WXK_DELETE] = "delete",

	[wx.WXK_SHIFT] = "shift",
	[wx.WXK_ALT] = "alt",
	[wx.WXK_CONTROL] = "ctrl",

	[wx.WXK_MENU] = "menu",

	[wx.WXK_PAUSE] = "pause",
	[wx.WXK_HOME] = "home",

	[wx.WXK_LEFT] = "a_left",
	[wx.WXK_RIGHT] = "a_right",
	[wx.WXK_UP] = "a_up",
	[wx.WXK_DOWN] = "a_down",

	[wx.WXK_PRINT] = "prtsc",
	[wx.WXK_INSERT] = "insert",

	[wx.WXK_NUMPAD1] = "num_1",
	[wx.WXK_NUMPAD2] = "num_2",
	[wx.WXK_NUMPAD3] = "num_3",
	[wx.WXK_NUMPAD4] = "num_4",
	[wx.WXK_NUMPAD5] = "num_5",
	[wx.WXK_NUMPAD6] = "num_6",
	[wx.WXK_NUMPAD7] = "num_7",
	[wx.WXK_NUMPAD8] = "num_8",
	[wx.WXK_NUMPAD9] = "num_9",
	[wx.WXK_NUMPAD0] = "num_0",

	[wx.WXK_MULTIPLY] = "*",
	[wx.WXK_ADD] = "+",
	[wx.WXK_SUBTRACT] = "-",
	[wx.WXK_DECIMAL] = ".",
	[wx.WXK_DIVIDE] = "/",

	[wx.WXK_NUMLOCK] = "numlock",

	[wx.WXK_PAGEUP] = "pgup",
	[wx.WXK_PAGEDOWN] = "pgdn",

	[wx.WXK_F1] = "f1",
	[wx.WXK_F2] = "f2",
	[wx.WXK_F3] = "f3",
	[wx.WXK_F4] = "f4",
	[wx.WXK_F5] = "f5",
	[wx.WXK_F6] = "f6",
	[wx.WXK_F7] = "f7",
	[wx.WXK_F8] = "f8",
	[wx.WXK_F9] = "f9",
	[wx.WXK_F10] = "f10",
	[wx.WXK_F11] = "f11",
	[wx.WXK_F12] = "f12",
	[wx.WXK_F13] = "f13",
	[wx.WXK_F14] = "f14",
	[wx.WXK_F15] = "f15",
	[wx.WXK_F16] = "f16",
	[wx.WXK_F17] = "f17",
	[wx.WXK_F18] = "f18",
	[wx.WXK_F19] = "f19",
	[wx.WXK_F20] = "f20",
	[wx.WXK_F21] = "f21",
	[wx.WXK_F22] = "f22",
	[wx.WXK_F23] = "f23",
	[wx.WXK_F24] = "f24",

	[wx.WXK_NUMPAD_SPACE] = "num_space",
	[wx.WXK_NUMPAD_TAB] = "num_tab",
	[wx.WXK_NUMPAD_ENTER] = "num_enter",

	[wx.WXK_NUMPAD_F1] = "num_f1",
	[wx.WXK_NUMPAD_F2] = "num_f2",
	[wx.WXK_NUMPAD_F3] = "num_f3",
	[wx.WXK_NUMPAD_F4] = "num_f4",

	[wx.WXK_NUMPAD_LEFT] = "num_left",
	[wx.WXK_NUMPAD_RIGHT] = "num_right",
	[wx.WXK_NUMPAD_UP] = "num_up",
	[wx.WXK_NUMPAD_DOWN] = "num_down",

	[wx.WXK_NUMPAD_HOME] = "num_home",
	[wx.WXK_NUMPAD_PAGEUP] = "num_pgup",
	[wx.WXK_NUMPAD_PAGEDOWN] = "num_pgdn",

	[wx.WXK_NUMPAD_END] = "num_end",
	[wx.WXK_NUMPAD_INSERT] = "num_ins",
	[wx.WXK_NUMPAD_DELETE] = "num_del",

	[wx.WXK_NUMPAD_MULTIPLY] = "num_mul",
	[wx.WXK_NUMPAD_ADD] = "num_add",
	[wx.WXK_NUMPAD_SUBTRACT] = "num_sub",
	[wx.WXK_NUMPAD_DIVIDE] = "num_div",

	[311] = "capslock",
	[383] = "num_5",

}
function getCode(evt) return evt:GetKeyCode() end

function getKey(id)
	
	if type(id) ~= "number" then id = getCode(id) or 0 end

	if id <= 32 or id > 96 then
		return tableChars[id]
	else
		return string.char(id)
	end
end

--Проверка на нажатость клавиши
function isKeyPressed(key)

	--Если аргумент не является строкой или числом, то предположим, что он - событие, и пробьём его по коду для события.
	if type(key) ~= "number" and type(key) ~= "string" then key = getCode(key) or 0 end

	--print(type(key), key)
	--Если ключ не является числом
	if not tonumber(key) then
		--print(true)

		--То циклим сначала по таблице символов
		for i in pairs(tableChars) do
			--print(tableChars[i], tostring(key))

			--Если ключ совпадает со строкой под циклическим идентификатором
			if key == tableChars[i] then 
			
				--То ключ становится этим идентификатором
				key = i
				--Выходим из цикла
				break
			
			end
		end
		
		--print("\n"..key)

		--Если всё таки символ не лежит в таблице и не является числом
		if not tonumber(key) then 

			--То будем циклить по диапазону активных символов
			for i = 32, 96 do

				--Если ключ всё таки совпадает с символом данного кода, то ключ становится этим кодом
				if key == string.char(i) then key = i end
				
			end
		end
	end

	--Возвращаем статус активности нажатия
	return wx.wxGetKeyState(tonumber(key) or 0) or false

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
