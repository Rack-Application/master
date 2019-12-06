# This is a Simple Rack Application that will display local time in HTML, JSON and XML 

## Goals


1. Understand request and response, methods, content-type, body ... https://developer.mozilla.org/en-US/docs/Web/HTTP
2. Understand Rack and Rack middlewares
3. Understand how to dynamically create Web documents with ERB (HTML, JSON, XML etc.. )
4. Create a small rack application to display the time in user timezone HTML, JSON, XML

## HTTP protocol flow


A client C (browser, curl) is requesting some resource from a server S (ruby, php, nodejs web application)

Request:
C -----> S

Response
S -----> C

Client ask a question: request "Do you have time in HTML?"
Server answers with a response "Yes, here is the time"


### Protocol

#### Server resources

path part of the URL

- /time
- /users
- /users/hery



#### Request

https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods

Composed of:
- Protocol (HTTP, HTTPS, websocket, grpc, ftp, ssh)
- Method (GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD, CONNECT, TRACE)
- path (example: /users, /users/hery, /)
- body 

```
HTTP/1.1
GET /time
Accept: text/html,application/json
```

#### Response

```
Status code: 200 (OK)
Content-Type: application/json

{
  "time": "2019-12-06 13:34:57 +0100"
}
```


-----------------------------------
#### Request

```
HTTP/1.1
GET /users/hema
Accept: text/html,application/json
```

#### Response

```
Status code: 404 (Not Found)
Content-Type: text/html


<html>
<body>
Sorry, we could not find the resource "/users/hema"
</body>
</html>
```


## Rack and Rack Middlewares



https://rack.github.io/

Ruby Webserver _**Interface**_ 
See definition of interface https://en.wikipedia.org/wiki/Interface_(computing)


Webserver is a process that evaluates the code on the server side and return a response
Interface is set of tools and instructions that will describe how different components can communicate.

- API application programming interface (ruby docs, )
- UI User interface
- GUI Graphical User **Interface**


Rack middleware interface: https://rack.github.io/

The middleware should:

- respond to `#call`
- `#call` takes a parameter environment 
- `#call` returns an Array of 3 components
    * status code (Integer)
    * Headers (Hash)
    * Object that responds to each  
    
    
### ERB Ruby Templating

https://docs.ruby-lang.org/en/2.6.0/ERB.html
