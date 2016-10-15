--Таблица с элементами
local Calculation = {
	Number 	= {}, 	--Таблица с числами, с которыми производятся операции
	Job 	= {} 	--Таблица с действиями, которые выполняется для чисел в таблице выше
}
local SavingNumber 			= "0" 	--Переменная, в которую будет сохранено текущее число
local isLogOpened 			= false --Переменная, отвечающая за то, открыта ли панель с историей счёта
local MEMORY 				= 0 	--Число в памяти для рассчёта через MC/MS/MR/M+/M-

--Функции для рассчёта
--Добавить число в таблицу
function addNumber(num) 

	local id 				= #Calculation.Number+1 --Создать переменную идентификатора, полученную увеличением длины таблицы на 1
	Calculation.Number[id] 	= num 					--Присвоить элементу с данным идентификатором в таблице значение числа
	SavingNumber 			= "0" 					--Обнулить сохраняющий номер
end

--Добавить функцию рассчёта
function addJob(job) --Аргументом функции является фраза, обозначающая операцию

	local id 				= #Calculation.Job+1 	--Таким же образом рассчитываем идентификатор для действия
	Calculation.Job[id] 	= job 					--И устанавливаем аргумент для функции

end

--Функция рассчёта значения
function calculateResult()
	local id = 1 									--Идентификатор для цикла (цикл по всей таблице Job)
	local result = Calculation.Number[id] or 0 		--Результирующее значение, которое будет рассчитываться

	while Calculation.Job[id] 		~= nil do

		if Calculation.Job[id] 		== Symbols.Plus then	result = result+(Calculation.Number[id+1] or 0)
		elseif Calculation.Job[id] 	== Symbols.Subs then	result = result-(Calculation.Number[id+1] or 0)
		elseif Calculation.Job[id] 	== Symbols.Mply then	result = result*(Calculation.Number[id+1] or 1)
		elseif Calculation.Job[id] 	== Symbols.Divd then	result = result/(Calculation.Number[id+1] or 1)

		elseif Calculation.Job[id] 	== Symbols.Sqrt then	result = math.sqrt(result) or 0
		elseif Calculation.Job[id] 	== Symbols.Perc then	result = ( result / 100) * (Calculation.Number[id+1] or 1)

		elseif Calculation.Job[id] 	== Symbols.Rvrs then	result = result^(-1)
		elseif Calculation.Job[id] 	== Symbols.Negv then	result = result*(-1)
		end

		if tostring(result) == "-0" then result = 0 end

		id = id+1

	end

	--Обнуляем
	clearResults()

	--По завершению цикла возвращаем результат
	return result
end
--Функция обнуления
function clearResults()

	--Обнуляем таблицу
	Calculation = { 
		Number = {},
		Job = {}
	}
	--Обнуляем текст в верхней строке калькулятора
	setText(ResultBox, "0")

	--Обнуляем сохраняющее число
	SavingNumber = "0"
end

local zeroClick = false --Переменная, отвечающая за то, чтобы ноль в десятичной дроби заменялся на число (12.0 -> 12.5)
local isUnaryOp = false --Переменная, которая будет являться проверкой на выполнение унарной операции (sqrt, 1/x, +-)

--Исполнение цикла для действий по нажатию на клавиши
for i, v in pairs(Buttons) do
	
	addEvent(v, "onMouseEnter", function()	setAlpha(v, 0.7)	end)
	addEvent(v, "onMouseLeave", function()	setAlpha(v, 1)		end)

	--Добавляется событие нажатия
	addEvent(v, "onMouseDown", function()

		--Переведём аргумент в строку
		i = tostring(i)

		if tonumber(i) then						--Если ключ цикла можно перевести в число (0-9)
			if isUnaryOp then return false end	--Если исполняется унарная операция, то закончить событие

			local text = getText(ResultBox)

			if text == Symbols.Inft then		--Если есть символ бесконечности
			
				SavingNumber 	= "" 				--Обнуляем всё
				text 		 	= ""				--И переменную с текстом
				setText(ResultBox,"") 				--Включая текст
			
			elseif SavingNumber == "0" then		--Если исходное число 0
			
				SavingNumber = "" 							--То обнуляем число
				text 		 = text:sub(1, text:len()-1)	--Вырезаем текст
			
			end

			if zeroClick then 								--Если была нажата точка
				if tostring(SavingNumber):find(".0") then 	--То если ноль найден перед точкой

					SavingNumber = tostring(SavingNumber):gsub(".0", ".") 	--Очищаем ноль
					text 		 = text:sub(1, text:len()-1) 				--Вырезаем из текста
				end

				zeroClick = false 											--Удаляется параметр
			end

			SavingNumber = tostring(SavingNumber..tonumber(i))	--Сохраняется номер
			setText(ResultBox, text..i)	 						--Обновляется символ

		else 						--Если нажатие не на число, то
			if i == "." then		--Если нажатие на точку

				if getText(ResultBox) == Symbols.Inft then	--При Error (заменённый символ бесконечности)		
					SavingNumber = 		"0" 	--Обнуляем всё
					setText(ResultBox,  "0") 	--Включая текст
				end
					
				--Если в числе уже есть точка, или совершается унарная операция, то закрыть событие
				if SavingNumber:find("%.") or isUnaryOp then return false end

				SavingNumber = SavingNumber..".0"				--Устанавливаем точку
				setText(ResultBox, getText(ResultBox)..".0")

				zeroClick = true								--Обозначаем, что мы нажали на точку

			--Если нажатие на математическое действие
			elseif 
				i == Symbols.Plus or 
				i == Symbols.Subs or 
				i == Symbols.Mply or 
				i == Symbols.Divd or 
				i == Symbols.Perc or 
				i == Symbols.Sqrt or 
				i == Symbols.Rvrs or 
				i == Symbols.Negv 
				then

					addNumber(tonumber(SavingNumber))
					addJob(i)

					setText(ResultBox, getText(ResultBox):gsub(Symbols.Inft, "0"))			--Заменить символ бесконечности

					if i == Symbols.Sqrt or i == Symbols.Rvrs or i == Symbols.Negv then		--Если операции унарные
						isUnaryOp 		= true 												--То соответственно сообщить об этом программе
						local startText = 
							i == Symbols.Sqrt and i.."(" 					or 
							i == Symbols.Rvrs and "1"..Symbols.Divd.."("	or
							i == Symbols.Negv and "-("  

						setText(ResultBox, startText..getText(ResultBox)..")")

					else 		--Если не унарные

						isUnaryOp 		= false --Сообщаем, что операция не унарная
						SavingNumber 	= "0"	--Обнуляем сохраняющий номер для новой операции

						--Обновляем текст
						setText(ResultBox, getText(ResultBox).." "..i.." 0")
					end

			--Если нажатие на клавишу Backspace
			elseif i == Symbols.Back then

				if isUnaryOp then return false end		--Если унарная операция, то закрыть событие

				local ls = SavingNumber:len() 			--Длина числа для удаления
				local text = getText(ResultBox) 		--Текст
				local lt = text:len() 					--Длина текста

				if text == "Error" then text = "0" lt = 1 SavingNumber = "0" ls = 1 end
		
				if SavingNumber:sub(ls-1, ls) == ".0" then 	--Если в числе последние 2 символа будут .0

					SavingNumber = SavingNumber:sub(1, ls-2)	--То уберём сразу два этих числа
					text = text:sub(1, lt-2)

				else 	--Если их найдено не будет

					SavingNumber = SavingNumber:sub(1, ls-1)	--То вычтем по одному символу текста
					text = text:sub(1, lt-1)
	
					if SavingNumber == "" then			--Если мы очистили подчистую	
						SavingNumber = "0" 				--То оставим хотя бы нолик 
						text = text.."0"
					end

					if SavingNumber:sub(ls-1, ls) == "." then	--Если последний символ - это точка
						SavingNumber = SavingNumber.."0" 		--То добавим к нему нолик, ведь проверка на наличие нолика уже была 
						text = text.."0"
					end

				end

				setText(ResultBox, text)	--Установим текст

			elseif i == "CE" then					--СЕ - обнуляет введённое на данный момент число 

				if isUnaryOp then return false end	--Если унарная операция, то закрыть событие

				local text 		= getText(ResultBox):sub(0, getText(ResultBox):len()-SavingNumber:len())
				SavingNumber	= "0"

				setText(ResultBox, text.."0")

			elseif i == "C" then					--С - чистит всё

				--Обнуляем все результаты и числа
				clearResults()
				SavingNumber = "0"
				zeroClick = false
				isUnaryOp = false
				setText(ResultBox, "0")		

			elseif i == Symbols.Result then			--Cчитаем результат

				local text = getText(ResultBox)
				
				addNumber(tonumber(SavingNumber))	--Добавить число в таблицу

				local res = calculateResult()		--Посчитать результат
				if tostring(res) == "inf" 
					or tostring(res) == "-nan" 
					then 
						res = Symbols.Inft 			--Если результат переходит в бесконечность, то заменить соответствующий текст символом
				end	

				----------------------------
				if res == 666 then
					res = "Welcome to HELL"
				end
				----------------------------

				if text == Symbols.Inft then text = "0" end
				addLogRes(text.." = "..res)			--Добавить элемент в лог

				if res == "Welcome to HELL" then res = 666 end
				setText(ResultBox, res)				--Установить текст

				if res == Symbols.Inft then res = 0 end		--Если заданный текст - бесконечность, то превратить её в ноль

				SavingNumber = getText(ResultBox)			--Обновить число
				zeroClick = false							--Обнулить параметры
				isUnaryOp = false

			elseif i == "Log" then		--Клавиша лога

				isLogOpened = not isLogOpened	--Замена переменной открытости лога
				if isLogOpened then 	setSize(MainFrame, 230*2, 304)	--Если закрыт - открыть
				else					setSize(MainFrame, 230, 304)	--Если открыт - закрыть
				end

			elseif i == "ClearLog" then	--Клавиша "очистить историю""

				setText(LogBox, " История:\n")

			elseif i == "MC" then		--Если MEMORY CLEAR
				
				MEMORY = 0
				print(MEMORY)

			elseif i == "MS" then		--Если MEMORY SAVE	
				
				MEMORY = SavingNumber
				print(MEMORY)

			elseif i == "MR" then		--Если MEMORY READ

				setText(ResultBox, 
					getText(ResultBox):sub(
						1, 
						-(tostring(SavingNumber):len()+1)
					)..MEMORY
				)
				
				SavingNumber = MEMORY
				print(MEMORY)

			elseif i == "M+" then

				MEMORY = MEMORY+SavingNumber
				print(MEMORY)

			elseif i == "M-" then
				
				MEMORY = MEMORY-SavingNumber
				print(MEMORY)

			end

		end
	end)
end

addEvent(MainFrame, "onKey", function(key) 

	key = getKey(key)				--Получим текстовую часть ключа (полное название кнопки на клавиатуре)

	for i = 0, 9 do 				--Циклим все кнопки

		if (key == tostring(i) 								--Если клавиша совпадает с параметром цикла
			or key == "num_"..tostring(i)) 
			and not isKeyPressed("shift") 
		then													

			executeEvent(Buttons[tostring(i)], "onMouseDown")	--То вызвать событие нажатия на данной клавише
		end
	end

	if key == "backspace" 
		then 						
			executeEvent(Buttons[Symbols.Back], "onMouseDown") end
	
	if key == "delete" 
		or key == "num_del" 
		then 	
			executeEvent(Buttons.CE, "onMouseDown") end
	
	if isKeyPressed("shift") and 
		(key == "delete" or key == "num_delete") 
		then 
			executeEvent(Buttons.C, "onMouseDown") end

	if key == "+" 
		or key == "num_add" 
		or (isKeyPressed("shift") and key == "=") 
		then 
			executeEvent(Buttons[Symbols.Plus], "onMouseDown") end

	if key == "-" 
		or key == "num_sub" 
		then 
			executeEvent(Buttons[Symbols.Subs], "onMouseDown") end

	if key == "*" 
		or key == "num_mul" 
		or (isKeyPressed("shift") and key == "8") 
		then 
			executeEvent(Buttons[Symbols.Mply], "onMouseDown") end

	if key == "/" 
		or key == "num_div" 
		then 
			executeEvent(Buttons[Symbols.Divd], "onMouseDown") end

	if isKeyPressed("shift") 
		and key == "5" 
		then 
			executeEvent(Buttons[Symbols.Perc], "onMouseDown") end
	
	if isKeyPressed("shift") 
		and (key == "-" or key == "num_sub") 
		then 
			executeEvent(Buttons[Symbols.Negv], "onMouseDown") end
	
	if key == "." 
		or key == "," 
		then 
			executeEvent(Buttons[Symbols.Dots], "onMouseDown") end

	if key == "enter" 
		or key == "num_enter" 
		or (key == "=" and not isKeyPressed("shift"))  
		then 
			executeEvent(Buttons[Symbols.Result], "onMouseDown") end

	if key == "M" then					--Клавиша для смены цветовой схемы
		
		for _, v in pairs(Buttons) do
			setAlpha(v, 1)
		end

		if DefaultColorScheme == colorScheme.Dark then		--Если дефолт - тёмная 
			DefaultColorScheme = colorScheme.Light			--То сменить на светлую
		else
			DefaultColorScheme = colorScheme.Dark			--Иначе - на тёмную
		end
		
		setColorScheme(DefaultColorScheme)					--Установить цветовую схему в зависимости от стандартной цветовой схемы

	end

end)
