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

	return frame
end

--Получение типа обьекта
function getType(element)
	local name = tostring(element)

	local typs = nil
	
	if name:find("wxButton") then 
		typs = "button"

	elseif name:find("wxStaticText") then 
		typs = "label"

	elseif name:find("wxTextCtrl") then 
		typs = "edit"

	elseif name:find("wxFrame") then 
		typs = "frame"

	else 
		typs = type(element) 
	end

	return typs

end


--Отцентровка элемента
function centerElement(element) 
	return element:Centre() 
end
function setPosition(element, x, y) return element:SetPosition(wx.wxPoint(x, y)) end
function setSize(element, w, h) return element:SetSize(wx.wxSize(w, h)) end
--Установка текста элементу
function setText(element, text) 
	if getType(element) == "edit" then 
		return element:SetValue(tostring(text))
	else 
		return element:SetLabel(tostring(text)) 
	end
end
--Получение текста от элемента
function getText(element) 
	if getType(element) == "edit" then 
		return element:GetValue()
	else 
		return element:GetLabel() 
	end
end

--Создание кнопки
function createButton(x, y, w, h, title, style, parent)

	--Если нет родительского элемента, то не запускать кнопку
	if not parent then return false end

	--Создать кнопку
	local button = wx.wxButton(parent, wx.wxID_ANY, tostring(title), wx.wxPoint(x, y) or wx.wxDefaultPosition, wx.wxSize(w, h) or wx.wxDefaultSize, style or wx.wxBU_EXACTFIT)
	
	return button
end

--Создание текстового поля
function createEdit(x, y, w, h, text, style, parent)

	--Если нет родительского элемента, то не создавать поле
	if not parent then return false end

	if style == "entab" then 
		style = wx.wxTE_PROCESS_ENTER + wx.wxTE_PROCESS_TAB

	elseif style == "read" then 
		style = wx.wxTE_READONLY

	elseif style == "mline" then 
		style = wx.wxTE_MULTILINE

	elseif style == "mread" then 
		style = wx.wxTE_MULTILINE + wx.wxTE_READONLY

	elseif style == "pass" then 
		style = wx.wxTE_PASSWORD + wx.wxTE_PROCESS_ENTER + wx.wxTE_PROCESS_TAB

	elseif style == "readpass" then 
		style = wx.wxTE_PASSWORD + wx.wxTE_READONLY 

	elseif style == "default" then 
		style = 0 
	end

	--Создание
	local edit = wx.wxTextCtrl(parent, wx.wxID_ANY, tostring(text), wx.wxPoint(x, y) or wx.wxDefaultPosition, wx.wxSize(w, h) or wx.wxDefaultSize, style or 0)

	return edit
end

--Создание обычного текста на экране
function createLabel(x, y, w, h, text, style, parent)

	--Если нет родительского элемента, то не создавать лейбл
	if not parent then return false end

	--Стиль текста, оф корс
	if style == "aleft" then 
		style = wx.wxALIGN_LEFT

	elseif style == "aright" then 
		style = wx.wxALIGN_RIGHT + wx.wxST_NO_AUTORESIZE

	elseif style == "acent" then 
		style = wx.wxALIGN_CENTRE_HORIZONTAL + wx.wxST_NO_AUTORESIZE 
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
		if name == "onClick" then 
			name = wx.wxEVT_COMMAND_BUTTON_CLICKED 
		end
	end

	--Создаём событие
	element:Connect(wx.wxID_ANY, name, funct) --Функция дефайнится с аргументом event

end

--Функция, которая должна стоять в конце каждого форм-файла.
function runApplication() return wx.wxGetApp():MainLoop() end


--Экземплы
--local f = createFrame(40, 40, 200, 210, "test", "full")
--centerElement(f)
--local b = createButton(10, 10, 180, 50, "Button", _, f)
--local e = createEdit(10, 70, 180, 60, "text1454", "default", f)
--local l = createLabel(10, 140, 180, 20, "Testing text", "aleft", f)

--executeEvent(b, "onClick", function(event)
--	setText(l, getText(e))
--end)

--wx.wxGetApp():MainLoop()
