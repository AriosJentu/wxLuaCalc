--Переменная, объявляющая все клавиши на форме
Buttons = {}

--Цветовая схема, используемая по умолчанию
DefaultColorScheme = colorScheme.Dark

--Создание формы:
MainFrame = createFrame(0, 0, 230, 304, "Калькулятор", "nores")
setAppIcon(MainFrame, APPDIR.."cicon.ico") --Устанавливаем иконку
centerElement(MainFrame)

--Координаты и размеры клавиш
local DefPS = {x=0, y=38, w=40, h=35, interval = 5}

--Цикл создание клавиш на форме
--i - порядковый номер ряда
--v - таблица, в которой хранятся идентификаторы и тексты для клавиш
--m - номер клавиши в ряду (колонка)
--n - идентификатор клавиши, который также является её текстом
for i, v in pairs(
	{
		{"MC", "MR", "MS", "M+", "M-"}, 						--Ряд клавиш Memory-действий
		{Symbols.Back, "CE", "C", Symbols.Negv, Symbols.Sqrt}, 	--Клавиши, исполнняющие действие стереть символ, также произведение числа на -1 и квадратный корень
		{"7", "8", "9", Symbols.Divd, Symbols.Perc}, 			--Ряд клавиш с цифрами 7, 8 и 9, также клавиши разделить и вычислить процент от числа
		{"4", "5", "6", Symbols.Mply, Symbols.Rvrs}, 			--Ряд клавиш с цифрами 4, 5 и 6, также умножение и кнопка разделения числа 1 на число, идущее в результат
		{"1", "2", "3", Symbols.Subs, Symbols.Result}, 			--Ряд клавиш от 1 до 3, клавиша вычитания и результата
		{"0", _, Symbols.Dots, Symbols.Plus} 					--Ряд с клавишами 0, точка и плюс, символ нижнего подчёркивания означает отсутствие элемента
	}) 
do 
	--Цикл по элементам вышенаписанных таблиц
	for m, n in pairs(v) do
		
		--Рассчёт координат
		local PosX, PosY, Width, Height = 
			DefPS.x + DefPS.w*(m-1) + DefPS.interval*m, 
			DefPS.y + DefPS.h*(i-1) + DefPS.interval*(i-1), 
			DefPS.w, 
			DefPS.h

		--Для клавиш ноль и равно поставить собственные размеры, а для пустой клавиши
		if n == "0" then Width = DefPS.w*2+DefPS.interval
		elseif n == nil then return false
		elseif n == Symbols.Result then Height = DefPS.h*2+DefPS.interval end

		Buttons[n] = createButton(PosX, PosY, Width, Height, n, _, MainFrame)
	end
end

--Верхнее поле ввода
ResultBox = createEdit(5, 5, DefPS.x + DefPS.w*4 + DefPS.interval*3, 27, "0", "rread", MainFrame)

--Кнопка Log - открывает историю рассчётов
Buttons.Log = createButton(
		DefPS.x + DefPS.w*4 + DefPS.interval*5,
		5, 
		DefPS.w, 
		27, 
		"Log", _, MainFrame)

--Текстовое поле, которое хранит в себе историю действий
LogBox = createEdit(230, 5, 225, 230, " История:\n", "mread", MainFrame)
setFont(LogBox,"Open Sans", 9)

--Кнопка для чистки истории
Buttons.ClearLog = createButton(230, 240, 225, 35, "Очистить", _, MainFrame)

function setColorScheme(tab)
	setColor(MainFrame, tab.Frame, tab.Text)

	local logInfo = getText(LogBox)
	setColor(LogBox, tab.EditB, tab.EditT)
	setText(LogBox, logInfo)

	for i, v in pairs(Buttons) do
		if not tonumber(i) and tostring(i) ~= "." then setColor(v, tab.ButD, tab.Text)
		else setColor(v, tab.ButL, tab.Text) end
	end

	setColor(Buttons[Symbols.Result], tab.Green, tab.ButM)
	setColor(Buttons.ClearLog, tab.Red, tab.ButM)

	setColor(ResultBox, tab.EditB, tab.EditT)
end
setColorScheme(DefaultColorScheme)

--Добавить в лог текст
function addLogRes(text)
	setText(LogBox, getText(LogBox).."\n "..text.."\n")
end
