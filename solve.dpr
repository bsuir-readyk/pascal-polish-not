program InfixToRPN;

uses
  SysUtils, Crt;

const
  MAX_STACK = 100;

type
  TStack = record
    items: array[1..MAX_STACK] of char;
    top: integer;
  end;

var
  expr: string;
  i: integer;
  stack: TStack;
  rpn: string;
  outputTable: array of array of string;
  tableRows: integer;

// Инициализация стека
procedure InitStack(var s: TStack);
begin
  s.top := 0;
end;

// Проверка пуст ли стек
function IsEmpty(var s: TStack): boolean;
begin
  IsEmpty := s.top = 0;
end;

// Добавление элемента в стек
procedure Push(var s: TStack; item: char);
begin
  if s.top < MAX_STACK then
  begin
    s.top := s.top + 1;
    s.items[s.top] := item;
  end
  else
    writeln('Стек переполнен');
end;

// Извлечение элемента из стека
function Pop(var s: TStack): char;
begin
  if not IsEmpty(s) then
  begin
    Pop := s.items[s.top];
    s.top := s.top - 1;
  end
  else
  begin
    Pop := ' ';
    writeln('Стек пуст');
  end;
end;

// Просмотр верхнего элемента стека
function Peek(var s: TStack): char;
begin
  if not IsEmpty(s) then
    Peek := s.items[s.top]
  else
    Peek := ' ';
end;

// Преобразование стека в строку для отображения в таблице
function StackToString(var s: TStack): string;
var
  i: integer;
begin
  result := '|-';
  for i := 1 to s.top do
    result := result + s.items[i];
  StackToString := result;
end;

// Определение приоритета оператора
function Priority(op: char): integer;
begin
  case op of
    '+', '-': Priority := 1;
    '*', '/': Priority := 2;
    '^': Priority := 3;
    '(': Priority := 0;
    else Priority := -1;
  end;
end;

// Добавление новой строки в таблицу
procedure AddTableRow(scanned: string; stack: string; rpn: string);
begin
  tableRows := tableRows + 1;
  SetLength(outputTable, tableRows, 3);
  outputTable[tableRows-1, 0] := scanned;
  outputTable[tableRows-1, 1] := stack;
  outputTable[tableRows-1, 2] := rpn;
end;

// Вывод таблицы на экран
procedure PrintTable;
var
  i: integer;
begin
  writeln('| Сканируемый символ | Содержание стека | Обратная польская запись |');
  writeln('|-------------------|-----------------|---------------------|');
  
  for i := 0 to tableRows - 1 do
  begin
    write('| ', outputTable[i, 0]);
    if Length(outputTable[i, 0]) < 18 then
      write(StringOfChar(' ', 18 - Length(outputTable[i, 0])));
    
    write(' | ', outputTable[i, 1]);
    if Length(outputTable[i, 1]) < 16 then
      write(StringOfChar(' ', 16 - Length(outputTable[i, 1])));
    
    write(' | ', outputTable[i, 2]);
    if Length(outputTable[i, 2]) < 20 then
      write(StringOfChar(' ', 20 - Length(outputTable[i, 2])));
    
    writeln(' |');
  end;
end;

// Определение является ли символ операндом
function IsOperand(ch: char): boolean;
begin
  IsOperand := (ch >= 'a') and (ch <= 'z') or (ch >= 'A') and (ch <= 'Z');
end;

// Основная функция преобразования
procedure InfixToRPN(infix: string);
var
  i: integer;
  ch, stackTop: char;
begin
  InitStack(stack);
  rpn := '';
  tableRows := 0;
  
  // Пустая первая строка таблицы
  AddTableRow('', StackToString(stack), '');
  
  for i := 1 to Length(infix) do
  begin
    ch := infix[i];
    
    if ch = ' ' then
      continue;
    
    // Если символ - операнд, добавляем его в выходную строку
    if IsOperand(ch) then
    begin
      rpn := rpn + ch;
      AddTableRow(ch, StackToString(stack), rpn);
    end
    // Если символ - открывающая скобка, помещаем в стек
    else if ch = '(' then
    begin
      Push(stack, ch);
      AddTableRow(ch, StackToString(stack), rpn);
    end
    // Если символ - закрывающая скобка, извлекаем из стека до открывающей скобки
    else if ch = ')' then
    begin
      while (not IsEmpty(stack)) and (Peek(stack) <> '(') do
      begin
        rpn := rpn + Pop(stack);
      end;
      if (not IsEmpty(stack)) and (Peek(stack) = '(') then
        stackTop := Pop(stack); // Удаляем открывающую скобку
      AddTableRow(ch, StackToString(stack), rpn);
    end
    // Если символ - оператор
    else
    begin
      while (not IsEmpty(stack)) and (Priority(Peek(stack)) >= Priority(ch)) do
      begin
        rpn := rpn + Pop(stack);
      end;
      Push(stack, ch);
      AddTableRow(ch, StackToString(stack), rpn);
    end;
  end;
  
  // Извлечение оставшихся операторов из стека
  while not IsEmpty(stack) do
  begin
    rpn := rpn + Pop(stack);
  end;
  
  // Последняя строка таблицы
  AddTableRow('', StackToString(stack), rpn);
end;

begin
  ClrScr;
  writeln('Введите выражение:');
  readln(expr);
  
  InfixToRPN(expr);
  PrintTable;
  
  writeln;
  writeln('Результат (ОПЗ): ', rpn);
  
  readln;
end.
