unit WebModuleUnit1;

interface

uses
  Winapi.ActiveX,
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  Data.Win.ADODB;

type
  TWebModule1 = class(TWebModule)
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse;
      var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TWebModule1.WebModule1DefaultHandlerAction(
  Sender: TObject;
  Request: TWebRequest;
  Response: TWebResponse;
  var Handled: Boolean);
var
  Connection: TADOConnection;
  Query: TADOQuery;
  CategoryQuery: TADOQuery;
  HTML: string;
  ProductID: string;
  CategoryID: string;
  SearchText: string;
begin

  Response.ContentType := 'text/html; charset=utf-8';

  Connection := TADOConnection.Create(nil);
  Query := TADOQuery.Create(nil);
  CategoryQuery := TADOQuery.Create(nil);

  try

    CoInitialize(nil);

    { ========================================== }
    { ПОДКЛЮЧЕНИЕ К MS SQL SERVER                }
    { ========================================== }

    Connection.LoginPrompt := False;

    Connection.ConnectionString :=
      'Provider=SQLOLEDB;' +
      'Data Source=.\SQLEXPRESS;' +
      'Initial Catalog=TechShopDB;' +
      'Integrated Security=SSPI;';

    Connection.Connected := True;

    { ========================================== }
    { ПОЛУЧАЕМ ПАРАМЕТРЫ ИЗ URL                  }
    { ========================================== }

    ProductID := Request.QueryFields.Values['product'];
    CategoryID := Request.QueryFields.Values['category'];
    SearchText := Request.QueryFields.Values['search'];

    { ========================================== }
    { ОБЩЕЕ HTML-ОФОРМЛЕНИЕ                     }
    { ========================================== }

    HTML :=
      '<!DOCTYPE html>' +
      '<html lang="ru">' +

      '<head>' +

      '<meta charset="UTF-8">' +
      '<meta name="viewport" content="width=device-width, initial-scale=1.0">' +

      '<title>TechShop - интернет-магазин техники</title>' +

      '<style>' +

      'body {' +
      'margin:0;' +
      'font-family:Arial,sans-serif;' +
      'background:#f4f6f8;' +
      'color:#222;' +
      '}' +

      'header {' +
      'background:#111827;' +
      'color:white;' +
      'padding:20px 60px;' +
      'display:flex;' +
      'justify-content:space-between;' +
      'align-items:center;' +
      'flex-wrap:wrap;' +
      '}' +

      '.logo {' +
      'font-size:28px;' +
      'font-weight:bold;' +
      '}' +

      'nav a {' +
      'color:white;' +
      'text-decoration:none;' +
      'margin-left:20px;' +
      '}' +

      'nav a:hover {' +
      'text-decoration:underline;' +
      '}' +

      '.hero {' +
      'background:white;' +
      'padding:55px 20px;' +
      'text-align:center;' +
      '}' +

      '.hero h1 {' +
      'font-size:42px;' +
      'margin:0 0 15px 0;' +
      '}' +

      '.hero p {' +
      'font-size:18px;' +
      'color:#666;' +
      '}' +

      '.container {' +
      'max-width:1100px;' +
      'margin:40px auto;' +
      'padding:0 20px;' +
      '}' +

      '.categories {' +
      'display:flex;' +
      'gap:15px;' +
      'flex-wrap:wrap;' +
      '}' +

      '.category {' +
      'background:white;' +
      'padding:20px;' +
      'border-radius:10px;' +
      'flex:1;' +
      'min-width:160px;' +
      'text-align:center;' +
      'box-shadow:0 2px 8px rgba(0,0,0,0.08);' +
      '}' +

      '.category a {' +
      'text-decoration:none;' +
      'color:#222;' +
      '}' +

      '.category:hover {' +
      'transform:translateY(-2px);' +
      '}' +

      '.products {' +
      'display:grid;' +
      'grid-template-columns:repeat(3,1fr);' +
      'gap:20px;' +
      '}' +

      '.product {' +
      'background:white;' +
      'padding:25px;' +
      'border-radius:10px;' +
      'box-shadow:0 2px 8px rgba(0,0,0,0.08);' +
      '}' +

      '.product h3 {' +
      'margin-top:10px;' +
      '}' +

      '.category-name {' +
      'display:inline-block;' +
      'background:#e5e7eb;' +
      'padding:5px 10px;' +
      'border-radius:5px;' +
      'font-size:13px;' +
      '}' +

      '.price {' +
      'font-size:22px;' +
      'font-weight:bold;' +
      'margin:15px 0;' +
      'color:#e91e63;' +
      '}' +

      '.button {' +
      'display:inline-block;' +
      'background:#2563eb;' +
      'color:white;' +
      'padding:10px 18px;' +
      'border-radius:6px;' +
      'text-decoration:none;' +
      '}' +

      '.button:hover {' +
      'background:#1d4ed8;' +
      '}' +

      '.back {' +
      'display:inline-block;' +
      'background:#6b7280;' +
      'color:white;' +
      'padding:10px 18px;' +
      'border-radius:6px;' +
      'text-decoration:none;' +
      'margin-top:20px;' +
      '}' +

      '.details {' +
      'background:white;' +
      'padding:35px;' +
      'border-radius:10px;' +
      'box-shadow:0 2px 8px rgba(0,0,0,0.08);' +
      '}' +

      '.search {' +
      'background:white;' +
      'padding:20px;' +
      'border-radius:10px;' +
      'margin-bottom:30px;' +
      '}' +

      '.search input {' +
      'padding:10px;' +
      'width:70%;' +
      'border:1px solid #ccc;' +
      'border-radius:5px;' +
      '}' +

      '.search button {' +
      'padding:10px 18px;' +
      'background:#2563eb;' +
      'color:white;' +
      'border:none;' +
      'border-radius:5px;' +
      'cursor:pointer;' +
      '}' +

      'footer {' +
      'margin-top:50px;' +
      'background:#111827;' +
      'color:white;' +
      'text-align:center;' +
      'padding:25px;' +
      '}' +

      '@media(max-width:800px) {' +
      '.products {' +
      'grid-template-columns:1fr;' +
      '}' +

      'header {' +
      'padding:20px;' +
      '}' +
      '}' +

      '</style>' +

      '</head>' +

      '<body>' +

      '<header>' +

      '<div class="logo">TechShop</div>' +

      '<nav>' +
      '<a href="?">Главная</a>' +
      '<a href="?">Каталог</a>' +
      '<a href="#categories">Категории</a>' +
      '<a href="#contacts">Контакты</a>' +
      '</nav>' +

      '</header>';

    { ========================================== }
    { СТРАНИЦА КОНКРЕТНОГО ТОВАРА                }
    { ========================================== }

    if ProductID <> '' then
    begin

      Query.Connection := Connection;

      Query.SQL.Text :=
        'SELECT p.ProductName, p.Price, p.Description, ' +
        'c.CategoryName ' +
        'FROM Products p ' +
        'LEFT JOIN Categories c ON p.CategoryID = c.CategoryID ' +
        'WHERE p.ProductID = ' + ProductID;

      Query.Open;

      HTML := HTML +

        '<div class="container">' +

        '<h1>Информация о товаре</h1>';

      if not Query.Eof then
      begin

        HTML := HTML +

          '<div class="details">' +

          '<span class="category-name">' +
          Query.FieldByName('CategoryName').AsString +
          '</span>' +

          '<h2>' +
          Query.FieldByName('ProductName').AsString +
          '</h2>' +

          '<p>' +
          Query.FieldByName('Description').AsString +
          '</p>' +

          '<div class="price">' +
          FormatFloat('#,##0',
            Query.FieldByName('Price').AsFloat) +
          ' ₸</div>' +

          '<a class="back" href="?">← Вернуться в каталог</a>' +

          '</div>';

      end
      else
      begin

        HTML := HTML +

          '<div class="details">' +

          '<h2>Товар не найден</h2>' +

          '<p>Такого товара нет в базе данных.</p>' +

          '<a class="back" href="?">← Вернуться в каталог</a>' +

          '</div>';

      end;

      HTML := HTML +

        '</div>';

    end

    { ========================================== }
    { ГЛАВНАЯ СТРАНИЦА / КАТАЛОГ                 }
    { ========================================== }

    else
    begin

      HTML := HTML +

        '<section class="hero">' +

        '<h1>Добро пожаловать в TechShop!</h1>' +

        '<p>Интернет-магазин современной техники</p>' +

        '</section>' +

        '<div class="container">';

      { ========================================== }
      { ПОИСК                                      }
      { ========================================== }

      HTML := HTML +

        '<div class="search">' +

        '<form method="get">' +

        '<input type="text" name="search" ' +
        'placeholder="Введите название товара..." ' +
        'value="' + SearchText + '">' +

        '<button type="submit">Поиск</button>' +

        '</form>' +

        '</div>';

      { ========================================== }
      { КАТЕГОРИИ                                  }
      { ========================================== }

      HTML := HTML +

        '<h2 id="categories">Категории товаров</h2>' +

        '<div class="categories">';

      CategoryQuery.Connection := Connection;

      CategoryQuery.SQL.Text :=
        'SELECT CategoryID, CategoryName ' +
        'FROM Categories ' +
        'ORDER BY CategoryID';

      CategoryQuery.Open;

      while not CategoryQuery.Eof do
      begin

        HTML := HTML +

          '<div class="category">' +

          '<a href="?category=' +
          CategoryQuery.FieldByName('CategoryID').AsString +
          '">' +

          '<h3>' +
          CategoryQuery.FieldByName('CategoryName').AsString +
          '</h3>' +

          '<p>Посмотреть товары</p>' +

          '</a>' +

          '</div>';

        CategoryQuery.Next;

      end;

      CategoryQuery.Close;

      HTML := HTML +

        '</div>' +

        '<h2 style="margin-top:40px;">Каталог товаров</h2>' +

        '<div class="products">';

      { ========================================== }
      { ЗАПРОС ТОВАРОВ                             }
      { ========================================== }

      Query.Connection := Connection;

      Query.SQL.Text :=
        'SELECT p.ProductID, p.ProductName, p.Price, ' +
        'p.Description, c.CategoryName ' +
        'FROM Products p ' +
        'LEFT JOIN Categories c ON p.CategoryID = c.CategoryID ';

      { ФИЛЬТР ПО КАТЕГОРИИ }

      if CategoryID <> '' then
      begin

        Query.SQL.Text :=
          Query.SQL.Text +
          'WHERE p.CategoryID = ' + CategoryID + ' ';

      end;

      { ПОИСК }

      if SearchText <> '' then
      begin

        if CategoryID <> '' then
          Query.SQL.Text :=
            Query.SQL.Text +
            'AND p.ProductName LIKE ''%' +
            StringReplace(SearchText, '''', '''''',
              [rfReplaceAll]) +
            '%'' '
        else
          Query.SQL.Text :=
            Query.SQL.Text +
            'WHERE p.ProductName LIKE ''%' +
            StringReplace(SearchText, '''', '''''',
              [rfReplaceAll]) +
            '%'' ';

      end;

      Query.SQL.Text :=
        Query.SQL.Text +
        'ORDER BY p.ProductID';

      Query.Open;

      if Query.Eof then
      begin

        HTML := HTML +

          '<p>По вашему запросу товары не найдены.</p>';

      end;

      while not Query.Eof do
      begin

        HTML := HTML +

          '<div class="product">' +

          '<span class="category-name">' +
          Query.FieldByName('CategoryName').AsString +
          '</span>' +

          '<h3>' +
          Query.FieldByName('ProductName').AsString +
          '</h3>' +

          '<p>' +
          Query.FieldByName('Description').AsString +
          '</p>' +

          '<div class="price">' +
          FormatFloat('#,##0',
            Query.FieldByName('Price').AsFloat) +
          ' ₸</div>' +

          '<a class="button" href="?product=' +
          Query.FieldByName('ProductID').AsString +
          '">' +

          'Подробнее' +

          '</a>' +

          '</div>';

        Query.Next;

      end;

      HTML := HTML +

        '</div>' +

        '<div style="margin-top:30px;">' +

        '<a class="back" href="?">Показать все товары</a>' +

        '</div>' +

        '</div>';

    end;

    { ========================================== }
    { FOOTER                                     }
    { ========================================== }

    HTML := HTML +

      '<footer id="contacts">' +

      '<p>© 2026 TechShop - интернет-магазин техники</p>' +

      '<p>Интернет-магазин современной техники</p>' +

      '</footer>' +

      '</body>' +

      '</html>';

    Response.Content := HTML;

    Handled := True;

  except

    on E: Exception do
    begin

      Response.Content :=

        '<!DOCTYPE html>' +

        '<html lang="ru">' +

        '<head>' +

        '<meta charset="UTF-8">' +

        '<title>Ошибка TechShop</title>' +

        '</head>' +

        '<body>' +

        '<div style="font-family:Arial;margin:50px;">' +

        '<h1>Ошибка подключения к базе данных</h1>' +

        '<p>' +

        E.Message +

        '</p>' +

        '<hr>' +

        '<p>' +

        'Проверьте подключение к SQL Server и базу TechShopDB.' +

        '</p>' +

        '</div>' +

        '</body>' +

        '</html>';

      Handled := True;

    end;

  end;

  Query.Close;
  Query.Free;

  CategoryQuery.Free;

  Connection.Close;
  Connection.Free;

  CoUninitialize;

end;

end.
