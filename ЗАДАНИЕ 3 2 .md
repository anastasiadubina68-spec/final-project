# 1. Подключение необходимых модулей 
uses
  Winapi.ActiveX, Используется для работы COM. Он необходим для корректной работы с Ado 
  

  System.SysUtils, System.Classes,Web.HTTPApp Базовые модули которые содержат стандартные функции Delphi
  

  Data.Win.ADODB; Используется для подключения БД к ADO 

# 2. Создаем веб модуль 
Основой WEB-приложения является веб-модуль: 

    TWebModule1 = class(TWebModule)
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
    Request: TWebRequest; Response: TWebResponse;
    var Handled: Boolean);

    Request содержит информацию о запросе пользователя, а Response используется для формирования ответа веб-страницы.

# 3. Подключаемся к базе данных 


Connection: TADOConnection;


  Query: TADOQuery;

  
  CategoryQuery: TADOQuery; 

  
begin


  Response.ContentType := 'text/html; charset=utf-8'; 

  
  Connection := TADOConnection.Create(nil); - Отвечает за соединения к Microsoft SQL Server

  
  Query := TADOQuery.Create(nil); Используется для выполнения запросов к таблицам товаров 

  
  CategoryQuery := TADOQuery.Create(nil); нужен для работы с запросами по категориям. 

# 4. Подключение к Microsoft SQL Server 

Connection.LoginPrompt := False;

    Connection.ConnectionString :=
      'Provider=SQLOLEDB;' +
      'Data Source=.\SQLEXPRESS;' +
      'Initial Catalog=TechShopDB;' +
      'Integrated Security=SSPI;';

Указываем провайдер, SQL сервер , название базы данных (TechShopDB) таким образом программа подключается к базе данных и получает возможность выполнять SQL-запросы.

После выполнения:Connection.Connected := True; программа устанавливает соединение с базой данных и получает возможность выполнять SQL-запросы.

# 5. Формирование страницы сайта 
TML-код страницы формируется в программе Delphi с помощью переменной HTML:

HTML :=
      '<!DOCTYPE html>' +
      '<html lang="ru">' +
      '<header>' +
'<div class="logo">TechShop</div>' + 

Добавляем навигацию сайта 

'<nav>' +
'<a href="?">Главная</a>' +
'<a href="?">Каталог</a>' +
'<a href="#categories">Категории</a>' +
'<a href="#contacts">Контакты</a>' +
'</nav>'

# 6. Отображение конкретного товара 

if ProductID <> '' then
Если клиент нажал кнопку подробнее то создается SQL запрос который получает название товара, цену, описание и категорию товара.
    begin

      Query.Connection := Connection;

      Query.SQL.Text :=

        'SELECT p.ProductName, p.Price, p.Description, ' +

        'c.CategoryName ' +

        'FROM Products p ' +

        'LEFT JOIN Categories c ON p.CategoryID = c.CategoryID ' +

        'WHERE p.ProductID = ' + ProductID;

# 7. Выводим на страницу каталог 

if not Query.Eof then   
Если товар есть на странице то пользователь получает конкретную информацию о товаре 

      begin

        HTML := HTML +

          '<div class="details">' +

          '<span class="category-name">' +

          Query.FieldByName('CategoryName').AsString +     - выводит категорию товара 

          '</span>' +

          '<h2>' +

          Query.FieldByName('ProductName').AsString +  - выводит название товара 

          '</h2>' +

          '<p>' +

          Query.FieldByName('Description').AsString +  -выводит описание товара 

          '</p>' +

          '<div class="price">' +

          FormatFloat('#,##0',

            Query.FieldByName('Price').AsFloat) +  -выводит стоимость товара 

  # 8. Если товар не найден то :

  if Query.Eof then
      begin

        HTML := HTML +

          '<p>По вашему запросу товары не найдены.</p>';

      end;
      
Программа проверяет наличие товара и если его нет то на экран Web страницы выводится "По вашему запросу товары не найдены."

# 9.Кнопка возврата в каталог

'<a class="back" href="?"> Вернуться в каталог</a>' 
После просмотра подробной информации о товаре пользователь может вернуться обратно в каталог используя кнопку 'Вернуться в каталог'

# 10.Поисковая система

Поиск реализован с помощью HTML-формы: '<form method="get">' 

HTML := HTML +

        '<div class="search">' +

        '<form method="get">' +

        '<input type="text" name="search" ' +
        'placeholder="Введите название товара..." ' +
        'value="' + SearchText + '">' +

        '<button type="submit">Поиск</button>' +

        '</form>' +

        '</div>';

После этого значение используется при формировании SQL-запроса к базе данных и в результате программа получает из базы данных только те товары, которые соответствуют поисковому запросу.


          




