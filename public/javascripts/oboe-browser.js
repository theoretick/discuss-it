// this file is the concatenation of several js files. See https://github.com/jimhigson/oboe-browser.js/tree/master/src for the unconcatenated source
window.oboe = (function  (window, Object, Array, Error, undefined ) {
/**
 * Partially complete a function.
 *
 * Eg:
 *    var add3 = partialComplete( function add(a,b){return a+b}, [3] );
 *
 *    add3(4) // gives 7
 */
var partialComplete = varArgs(function( fn, boundArgs ) {

      return varArgs(function( callArgs ) {

         return fn.apply(this, boundArgs.concat(callArgs));
      });
   }),


/**
 * Compose zero or more functions:
 *
 *    compose(f1, f2, f3)(x) = f1(f2(f3(x))))
 *
 * The last (inner-most) function may take more than one parameter:
 *
 *    compose(f1, f2, f3)(x,y) = f1(f2(f3(x,y))))
 */
   compose = varArgs(function(fns) {

      var fnsList = arrayAsList(fns);

      function next(params, curFn) {
         return [apply(params, curFn)];
      }

      return varArgs(function(startParams){

         return foldR(next, startParams, fnsList)[0];
      });
   }),

/**
 * Call a list of functions with the same args until one returns a
 * truthy result. Similar to the || operator.
 *
 * So:
 *      lazyUnion([f1,f2,f3 ... fn])( p1, p2 ... pn )
 *
 * Is equivalent to:
 *      apply([p1, p2 ... pn], f1) ||
 *      apply([p1, p2 ... pn], f2) ||
 *      apply([p1, p2 ... pn], f3) ... apply(fn, [p1, p2 ... pn])
 *
 * @returns the first return value that is given that is truthy.
 */
   lazyUnion = varArgs(function(fns) {

      return varArgs(function(params){

         var maybeValue;

         for (var i = 0; i < len(fns); i++) {

            maybeValue = apply(params, fns[i]);

            if( maybeValue ) {
               return maybeValue;
            }
         }
      });
   });

/**
 * This file declares various pieces of functional programming.
 *
 * This isn't a general purpose functional library, to keep things small it
 * has just the parts useful for Oboe.js.
 */


/**
 * Call a single function with the given arguments array.
 * Basically, a functional-style version of the OO-style Function#apply for
 * when we don't care about the context ('this') of the call.
 *
 * The order of arguments allows partial completion of the arguments array
 */
function apply(args, fn) {
   return fn.apply(undefined, args);
}

/**
 * Define variable argument functions but cut out all that tedious messing about
 * with the arguments object. Delivers the variable-length part of the arguments
 * list as an array.
 *
 * Eg:
 *
 * var myFunction = varArgs(
 *    function( fixedArgument, otherFixedArgument, variableNumberOfArguments ){
 *       console.log( variableNumberOfArguments );
 *    }
 * )
 *
 * myFunction('a', 'b', 1, 2, 3); // logs [1,2,3]
 *
 * var myOtherFunction = varArgs(function( variableNumberOfArguments ){
 *    console.log( variableNumberOfArguments );
 * })
 *
 * myFunction(1, 2, 3); // logs [1,2,3]
 *
 */
function varArgs(fn){

   var numberOfFixedArguments = fn.length -1;

   return function(){

      var numberOfVaraibleArguments = arguments.length - numberOfFixedArguments,

          argumentsToFunction = Array.prototype.slice.call(arguments);

      // remove the last n element from the array and append it onto the end of
      // itself as a sub-array
      argumentsToFunction.push(
         argumentsToFunction.splice(numberOfFixedArguments, numberOfVaraibleArguments)
      );

      return fn.apply( this, argumentsToFunction );
   }
}


/**
 * Swap the order of parameters to a binary function
 *
 * A bit like this flip: http://zvon.org/other/haskell/Outputprelude/flip_f.html
 */
function flip(fn){
   return function(a, b){
      return fn(b,a);
   }
}


/**
 * Create a function which is the intersection of two other functions.
 *
 * Like the && operator, if the first is truthy, the second is never called,
 * otherwise the return value from the second is returned.
 */
function lazyIntersection(fn1, fn2) {

   return function (param) {

      return fn1(param) && fn2(param);
   };
}


/**
 * This file defines some loosely associated syntactic sugar for
 * Javascript programming
 */


/**
 * Returns true if the given candidate is of type T
 */
function isOfType(T, maybeSomething){
   return maybeSomething && maybeSomething.constructor === T;
}
function pluck(key, object){
   return object[key];
}

var attr = partialComplete(partialComplete, pluck),
    len = attr('length'),
    isString = partialComplete(isOfType, String);

/**
 * I don't like saying this:
 *
 *    foo !=== undefined
 *
 * because of the double-negative. I find this:
 *
 *    defined(foo)
 *
 * easier to read.
 */
function defined( value ) {
   return value !== undefined;
}

function always(){return true}

/**
 * Returns true if object o has a key named like every property in
 * the properties array. Will give false if any are missing, or if o
 * is not an object.
 */
function hasAllProperties(fieldList, o) {

   return      (o instanceof Object)
            &&
               all(function (field) {
                  return (field in o);
               }, fieldList);
}
/**
 * Like cons in Lisp
 */
function cons(x, xs) {

   /* Internally lists are linked 2-element Javascript arrays.

      So that lists are all immutable we Object.freeze in newer
      Javascript runtimes.

      In older engines freeze should have been polyfilled as the
      identity function. */
   return Object.freeze([x,xs]);
}

/**
 * The empty list
 */
var emptyList = null,

/**
 * Get the head of a list.
 *
 * Ie, head(cons(a,b)) = a
 */
    head = attr(0),

/**
 * Get the tail of a list.
 *
 * Ie, head(cons(a,b)) = a
 */
    tail = attr(1);


/**
 * Converts an array to a list
 *
 *    asList([a,b,c])
 *
 * is equivalent to:
 *
 *    cons(a, cons(b, cons(c, emptyList)))
 **/
function arrayAsList(inputArray){

   return reverseList(
      inputArray.reduce(
         flip(cons),
         emptyList
      )
   );
}

/**
 * A varargs version of arrayAsList. Works a bit like list
 * in LISP.
 *
 *    list(a,b,c)
 *
 * is equivalent to:
 *
 *    cons(a, cons(b, cons(c, emptyList)))
 */
var list = varArgs(arrayAsList);

/**
 * Convert a list back to a js native array
 */
function listAsArray(list){

   return foldR( function(arraySoFar, listItem){

      arraySoFar.unshift(listItem);
      return arraySoFar;

   }, [], list );

}

/**
 * Map a function over a list
 */
function map(fn, list) {

   return list
            ? cons(fn(head(list)), map(fn,tail(list)))
            : emptyList
            ;
}

/**
 * foldR implementation. Reduce a list down to a single value.
 *
 * @pram {Function} fn     (rightEval, curVal) -> result
 */
function foldR(fn, startValue, list) {

   return list
            ? fn(foldR(fn, startValue, tail(list)), head(list))
            : startValue
            ;
}

/**
 * Returns true if the given function holds for every item in
 * the list, false otherwise
 */
function all(fn, list) {

   return !list ||
          fn(head(list)) && all(fn, tail(list));
}

/**
 * Apply a function to every item in a list
 *
 * This doesn't make any sense if we're doing pure functional because
 * it doesn't return anything. Hence, this is only really useful if fn
 * has side-effects.
 */
function each(fn, list) {

   if( list ){
      fn(head(list));
      each(fn, tail(list));
   }
}

/**
 * Reverse the order of a list
 */
function reverseList(list){

   // js re-implementation of 3rd solution from:
   //    http://www.haskell.org/haskellwiki/99_questions/Solutions/5
   function reverseInner( list, reversedAlready ) {
      if( !list ) {
         return reversedAlready;
      }

      return reverseInner(tail(list), cons(head(list), reversedAlready))
   }

   return reverseInner(list, emptyList);
}
;(function (clarinet) {
  // non node-js needs to set clarinet debug on root
  var env
    , fastlist
    ;

if(typeof process === 'object' && process.env) env = process.env;
else env = window;

if(typeof FastList === 'function') {
  fastlist = FastList;
} else if (typeof require === 'function') {
  try { fastlist = require('fast-list'); } catch (exc) { fastlist = Array; }
} else fastlist = Array;

  clarinet.parser            = function (opt) { return new CParser(opt);};
  clarinet.CParser           = CParser;
  clarinet.CStream           = CStream;
  clarinet.createStream      = createStream;
  clarinet.MAX_BUFFER_LENGTH = 64 * 1024;
  clarinet.DEBUG             = (env.CDEBUG==='debug');
  clarinet.INFO              = (env.CDEBUG==='debug' || env.CDEBUG==='info');
  clarinet.EVENTS            =
    [ "value"
    , "string"
    , "key"
    , "openobject"
    , "closeobject"
    , "openarray"
    , "closearray"
    , "error"
    , "end"
    , "ready"
    ];

  var buffers     = [ "textNode", "numberNode" ]
    , streamWraps = clarinet.EVENTS.filter(function (ev) {
          return ev !== "error" && ev !== "end";
        })
    , S           = 0
    , Stream
    ;

  clarinet.STATE =
    { BEGIN                             : S++
    , VALUE                             : S++ // general stuff
    , OPEN_OBJECT                       : S++ // {
    , CLOSE_OBJECT                      : S++ // }
    , OPEN_ARRAY                        : S++ // [
    , CLOSE_ARRAY                       : S++ // ]
    , TEXT_ESCAPE                       : S++ // \ stuff
    , STRING                            : S++ // ""
    , BACKSLASH                         : S++
    , END                               : S++ // No more stack
    , OPEN_KEY                          : S++ // , "a"
    , CLOSE_KEY                         : S++ // :
    , TRUE                              : S++ // r
    , TRUE2                             : S++ // u
    , TRUE3                             : S++ // e
    , FALSE                             : S++ // a
    , FALSE2                            : S++ // l
    , FALSE3                            : S++ // s
    , FALSE4                            : S++ // e
    , NULL                              : S++ // u
    , NULL2                             : S++ // l
    , NULL3                             : S++ // l
    , NUMBER_DECIMAL_POINT              : S++ // .
    , NUMBER_DIGIT                      : S++ // [0-9]
    };

  for (var s_ in clarinet.STATE) clarinet.STATE[clarinet.STATE[s_]] = s_;

  // switcharoo
  S = clarinet.STATE;

  if (!Object.create) {
    Object.create = function (o) {
      function f () { this["__proto__"] = o; }
      f.prototype = o;
      return new f;
    };
  }

  if (!Object.getPrototypeOf) {
    Object.getPrototypeOf = function (o) {
      return o["__proto__"];
    };
  }

  if (!Object.keys) {
    Object.keys = function (o) {
      var a = [];
      for (var i in o) if (o.hasOwnProperty(i)) a.push(i);
      return a;
    };
  }

  function checkBufferLength (parser) {
    var maxAllowed = Math.max(clarinet.MAX_BUFFER_LENGTH, 10)
      , maxActual = 0
      ;
    for (var i = 0, l = buffers.length; i < l; i ++) {
      var len = parser[buffers[i]].length;
      if (len > maxAllowed) {
        switch (buffers[i]) {
          case "text":
            closeText(parser);
          break;

          default:
            error(parser, "Max buffer length exceeded: "+ buffers[i]);
        }
      }
      maxActual = Math.max(maxActual, len);
    }
    parser.bufferCheckPosition = (clarinet.MAX_BUFFER_LENGTH - maxActual)
                               + parser.position;
  }

  function clearBuffers (parser) {
    for (var i = 0, l = buffers.length; i < l; i ++) {
      parser[buffers[i]] = "";
    }
  }

  var stringTokenPattern = /[\\"\n]/g;

  function CParser (opt) {
    if (!(this instanceof CParser)) return new CParser (opt);

    var parser = this;
    clearBuffers(parser);
    parser.bufferCheckPosition = clarinet.MAX_BUFFER_LENGTH;
    parser.q        = parser.c = parser.p = "";
    parser.opt      = opt || {};
    parser.closed   = parser.closedRoot = parser.sawRoot = false;
    parser.tag      = parser.error = null;
    parser.state    = S.BEGIN;
    parser.stack    = new fastlist();
    // mostly just for error reporting
    parser.position = parser.column = 0;
    parser.line     = 1;
    parser.slashed  = false;
    parser.unicodeI = 0;
    parser.unicodeS = null;
    emit(parser, "onready");
  }

  CParser.prototype =
    { end    : function () { end(this); }
    , write  : write
    , resume : function () { this.error = null; return this; }
    , close  : function () { return this.write(null); }
    };

  try        { Stream = require("stream").Stream; }
  catch (ex) { Stream = function () {}; }

  function createStream (opt) { return new CStream(opt); }

  function CStream (opt) {
    if (!(this instanceof CStream)) return new CStream(opt);

    this._parser = new CParser(opt);
    this.writable = true;
    this.readable = true;

    var me = this;
    Stream.apply(me);

    this._parser.onend = function () { me.emit("end"); };
    this._parser.onerror = function (er) {
      me.emit("error", er);
      me._parser.error = null;
    };

    streamWraps.forEach(function (ev) {
      Object.defineProperty(me, "on" + ev,
        { get          : function () { return me._parser["on" + ev]; }
        , set          : function (h) {
            if (!h) {
              me.removeAllListeners(ev);
              me._parser["on"+ev] = h;
              return h;
            }
            me.on(ev, h);
          }
        , enumerable   : true
        , configurable : false
        });
    });
  }

  CStream.prototype = Object.create(Stream.prototype,
    { constructor: { value: CStream } });

  CStream.prototype.write = function (data) {
    this._parser.write(data.toString());
    this.emit("data", data);
    return true;
  };

  CStream.prototype.end = function (chunk) {
    if (chunk && chunk.length) this._parser.write(chunk.toString());
    this._parser.end();
    return true;
  };

  CStream.prototype.on = function (ev, handler) {
    var me = this;
    if (!me._parser["on"+ev] && streamWraps.indexOf(ev) !== -1) {
      me._parser["on"+ev] = function () {
        var args = arguments.length === 1 ? [arguments[0]]
                 : Array.apply(null, arguments);
        args.splice(0, 0, ev);
        me.emit.apply(me, args);
      };
    }
    return Stream.prototype.on.call(me, ev, handler);
  };

  CStream.prototype.destroy = function () {
    clearBuffers(this._parser);
    this.emit("close");
  };

  function emit(parser, event, data) {
    if(clarinet.INFO) console.log('-- emit', event, data);
    if (parser[event]) parser[event](data);
  }

  function emitNode(parser, event, data) {
    closeValue(parser);
    emit(parser, event, data);
  }

  function closeValue(parser, event) {
    parser.textNode = textopts(parser.opt, parser.textNode);
    if (parser.textNode) {
      emit(parser, (event ? event : "onvalue"), parser.textNode);
    }
    parser.textNode = "";
  }

  function closeNumber(parser) {
    if (parser.numberNode)
      emit(parser, "onvalue", parseFloat(parser.numberNode));
    parser.numberNode = "";
  }

  function textopts (opt, text) {
    if (opt.trim) text = text.trim();
    if (opt.normalize) text = text.replace(/\s+/g, " ");
    return text;
  }

  function error (parser, er) {
    closeValue(parser);
    er += "\nLine: "+parser.line+
          "\nColumn: "+parser.column+
          "\nChar: "+parser.c;
    er = new Error(er);
    parser.error = er;
    emit(parser, "onerror", er);
    return parser;
  }

  function end(parser) {
    if (parser.state !== S.VALUE) error(parser, "Unexpected end");
    closeValue(parser);
    parser.c      = "";
    parser.closed = true;
    emit(parser, "onend");
    CParser.call(parser, parser.opt);
    return parser;
  }

  function write (chunk) {
    var parser = this;
    if (this.error) throw this.error;
    if (parser.closed) return error(parser,
      "Cannot write after close. Assign an onready handler.");
    if (chunk === null) return end(parser);
    var i = 0, c = chunk[0], p = parser.p;
    if (clarinet.DEBUG) console.log('write -> [' + chunk + ']');
    while (c) {
      p = c;
      parser.c = c = chunk.charAt(i++);
      // if chunk doesnt have next, like streaming char by char
      // this way we need to check if previous is really previous
      // if not we need to reset to what the parser says is the previous
      // from buffer
      if(p !== c ) parser.p = p;
      else p = parser.p;

      if(!c) break;

      if (clarinet.DEBUG) console.log(i,c,clarinet.STATE[parser.state]);
      parser.position ++;
      if (c === "\n") {
        parser.line ++;
        parser.column = 0;
      } else parser.column ++;
      switch (parser.state) {

        case S.BEGIN:
          if (c === "{") parser.state = S.OPEN_OBJECT;
          else if (c === "[") parser.state = S.OPEN_ARRAY;
          else if (c !== '\r' && c !== '\n' && c !== ' ' && c !== '\t')
            error(parser, "Non-whitespace before {[.");
        continue;

        case S.OPEN_KEY:
        case S.OPEN_OBJECT:
          if (c === '\r' || c === '\n' || c === ' ' || c === '\t') continue;
          if(parser.state === S.OPEN_KEY) parser.stack.push(S.CLOSE_KEY);
          else {
            if(c === '}') {
              emit(parser, 'onopenobject');
              emit(parser, 'oncloseobject');
              parser.state = parser.stack.pop() || S.VALUE;
              continue;
            } else  parser.stack.push(S.CLOSE_OBJECT);
          }
          if(c === '"') parser.state = S.STRING;
          else error(parser, "Malformed object key should start with \"");
        continue;

        case S.CLOSE_KEY:
        case S.CLOSE_OBJECT:
          if (c === '\r' || c === '\n' || c === ' ' || c === '\t') continue;
          var event = (parser.state === S.CLOSE_KEY) ? 'key' : 'object';
          if(c===':') {
            if(parser.state === S.CLOSE_OBJECT) {
              parser.stack.push(S.CLOSE_OBJECT);
              closeValue(parser, 'onopenobject');
            } else closeValue(parser, 'onkey');
            parser.state  = S.VALUE;
          } else if (c==='}') {
            emitNode(parser, 'oncloseobject');
            parser.state = parser.stack.pop() || S.VALUE;
          } else if(c===',') {
            if(parser.state === S.CLOSE_OBJECT)
              parser.stack.push(S.CLOSE_OBJECT);
            closeValue(parser);
            parser.state  = S.OPEN_KEY;
          } else error(parser, 'Bad object');
        continue;

        case S.OPEN_ARRAY: // after an array there always a value
        case S.VALUE:
          if (c === '\r' || c === '\n' || c === ' ' || c === '\t') continue;
          if(parser.state===S.OPEN_ARRAY) {
            emit(parser, 'onopenarray');
            parser.state = S.VALUE;
            if(c === ']') {
              emit(parser, 'onclosearray');
              parser.state = parser.stack.pop() || S.VALUE;
              continue;
            } else {
              parser.stack.push(S.CLOSE_ARRAY);
            }
          }
               if(c === '"') parser.state = S.STRING;
          else if(c === '{') parser.state = S.OPEN_OBJECT;
          else if(c === '[') parser.state = S.OPEN_ARRAY;
          else if(c === 't') parser.state = S.TRUE;
          else if(c === 'f') parser.state = S.FALSE;
          else if(c === 'n') parser.state = S.NULL;
          else if(c === '-') { // keep and continue
            parser.numberNode += c;
          } else if(c==='0') {
            parser.numberNode += c;
            parser.state = S.NUMBER_DIGIT;
          } else if('123456789'.indexOf(c) !== -1) {
            parser.numberNode += c;
            parser.state = S.NUMBER_DIGIT;
          } else               error(parser, "Bad value");
        continue;

        case S.CLOSE_ARRAY:
          if(c===',') {
            parser.stack.push(S.CLOSE_ARRAY);
            closeValue(parser, 'onvalue');
            parser.state  = S.VALUE;
          } else if (c===']') {
            emitNode(parser, 'onclosearray');
            parser.state = parser.stack.pop() || S.VALUE;
          } else if (c === '\r' || c === '\n' || c === ' ' || c === '\t')
              continue;
          else error(parser, 'Bad array');
        continue;

        case S.STRING:
          // thanks thejh, this is an about 50% performance improvement.
          var starti              = i-1
            , slashed = parser.slashed
            , unicodeI = parser.unicodeI
            ;
          STRING_BIGLOOP: while (true) {
            if (clarinet.DEBUG)
              console.log(i,c,clarinet.STATE[parser.state]
                         ,slashed);
            // zero means "no unicode active". 1-4 mean "parse some more". end after 4.
            while (unicodeI > 0) {
              parser.unicodeS += c;
              c = chunk.charAt(i++);
              if (unicodeI === 4) {
                // TODO this might be slow? well, probably not used too often anyway
                parser.textNode += String.fromCharCode(parseInt(parser.unicodeS, 16));
                unicodeI = 0;
                starti = i-1;
              } else {
                unicodeI++;
              }
              // we can just break here: no stuff we skipped that still has to be sliced out or so
              if (!c) break STRING_BIGLOOP;
            }
            if (c === '"' && !slashed) {
              parser.state = parser.stack.pop() || S.VALUE;
              parser.textNode += chunk.substring(starti, i-1);
              if(!parser.textNode) {
                 emit(parser, "onvalue", "");
              }
              break;
            }
            if (c === '\\' && !slashed) {
              slashed = true;
              parser.textNode += chunk.substring(starti, i-1);
              c = chunk.charAt(i++);
              if (!c) break;
            }
            if (slashed) {
              slashed = false;
                   if (c === 'n') { parser.textNode += '\n'; }
              else if (c === 'r') { parser.textNode += '\r'; }
              else if (c === 't') { parser.textNode += '\t'; }
              else if (c === 'f') { parser.textNode += '\f'; }
              else if (c === 'b') { parser.textNode += '\b'; }
              else if (c === 'u') {
                // \uxxxx. meh!
                unicodeI = 1;
                parser.unicodeS = '';
              } else {
                parser.textNode += c;
              }
              c = chunk.charAt(i++);
              starti = i-1;
              if (!c) break;
              else continue;
            }

            stringTokenPattern.lastIndex = i;
            var reResult = stringTokenPattern.exec(chunk);
            if (reResult === null) {
              i = chunk.length+1;
              parser.textNode += chunk.substring(starti, i-1);
              break;
            }
            i = reResult.index+1;
            c = chunk.charAt(reResult.index);
            if (!c) {
              parser.textNode += chunk.substring(starti, i-1);
              break;
            }
          }
          parser.slashed = slashed;
          parser.unicodeI = unicodeI;
        continue;

        case S.TRUE:
          if (c==='')  continue; // strange buffers
          if (c==='r') parser.state = S.TRUE2;
          else error(parser, 'Invalid true started with t'+ c);
        continue;

        case S.TRUE2:
          if (c==='')  continue;
          if (c==='u') parser.state = S.TRUE3;
          else error(parser, 'Invalid true started with tr'+ c);
        continue;

        case S.TRUE3:
          if (c==='') continue;
          if(c==='e') {
            emit(parser, "onvalue", true);
            parser.state = parser.stack.pop() || S.VALUE;
          } else error(parser, 'Invalid true started with tru'+ c);
        continue;

        case S.FALSE:
          if (c==='')  continue;
          if (c==='a') parser.state = S.FALSE2;
          else error(parser, 'Invalid false started with f'+ c);
        continue;

        case S.FALSE2:
          if (c==='')  continue;
          if (c==='l') parser.state = S.FALSE3;
          else error(parser, 'Invalid false started with fa'+ c);
        continue;

        case S.FALSE3:
          if (c==='')  continue;
          if (c==='s') parser.state = S.FALSE4;
          else error(parser, 'Invalid false started with fal'+ c);
        continue;

        case S.FALSE4:
          if (c==='')  continue;
          if (c==='e') {
            emit(parser, "onvalue", false);
            parser.state = parser.stack.pop() || S.VALUE;
          } else error(parser, 'Invalid false started with fals'+ c);
        continue;

        case S.NULL:
          if (c==='')  continue;
          if (c==='u') parser.state = S.NULL2;
          else error(parser, 'Invalid null started with n'+ c);
        continue;

        case S.NULL2:
          if (c==='')  continue;
          if (c==='l') parser.state = S.NULL3;
          else error(parser, 'Invalid null started with nu'+ c);
        continue;

        case S.NULL3:
          if (c==='') continue;
          if(c==='l') {
            emit(parser, "onvalue", null);
            parser.state = parser.stack.pop() || S.VALUE;
          } else error(parser, 'Invalid null started with nul'+ c);
        continue;

        case S.NUMBER_DECIMAL_POINT:
          if(c==='.') {
            parser.numberNode += c;
            parser.state       = S.NUMBER_DIGIT;
          } else error(parser, 'Leading zero not followed by .');
        continue;

        case S.NUMBER_DIGIT:
          if('0123456789'.indexOf(c) !== -1) parser.numberNode += c;
          else if (c==='.') {
            if(parser.numberNode.indexOf('.')!==-1)
              error(parser, 'Invalid number has two dots');
            parser.numberNode += c;
          } else if (c==='e' || c==='E') {
            if(parser.numberNode.indexOf('e')!==-1 ||
               parser.numberNode.indexOf('E')!==-1 )
               error(parser, 'Invalid number has two exponential');
            parser.numberNode += c;
          } else if (c==="+" || c==="-") {
            if(!(p==='e' || p==='E'))
              error(parser, 'Invalid symbol in number');
            parser.numberNode += c;
          } else {
            closeNumber(parser);
            i--; // go back one
            parser.state = parser.stack.pop() || S.VALUE;
          }
        continue;

        default:
          error(parser, "Unknown state: " + parser.state);
      }
    }
    if (parser.position >= parser.bufferCheckPosition)
      checkBufferLength(parser);
    return parser;
  }

})(typeof exports === "undefined" ? clarinet = {} : exports);


/**
 * A bridge used to assign stateless functions to listen to clarinet.
 *
 * As well as the parameter from clarinet, each callback will also be passed
 * the result of the last callback.
 *
 * This may also be used to clear all listeners by assigning zero handlers:
 *
 *    clarinetListenerAdaptor( clarinet, {} )
 */
function clarinetListenerAdaptor(clarinetParser, handlers){

   var state;

   clarinet.EVENTS.forEach(function(eventName){

      var handlerFunction = handlers[eventName];

      clarinetParser['on'+eventName] = handlerFunction &&
                                       function(param) {
                                          state = handlerFunction( state, param);
                                       };
   });
}
function httpTransport(){
   return new XMLHttpRequest();
}

/**
 * A wrapper around the browser XmlHttpRequest object that raises an
 * event whenever a new part of the response is available.
 *
 * In older browsers progressive reading is impossible so all the
 * content is given in a single call. For newer ones several events
 * should be raised, allowing progressive interpretation of the response.
 *
 * @param {Function} fire a function to pass events to when something happens
 * @param {Function} on a function to use to subscribe to events
 * @param {XMLHttpRequest} xhr the xhr to use as the transport. Under normal
 *          operation, will have been created using httpTransport() above
 *          but for tests a stub can be provided instead.
 * @param {String} method one of 'GET' 'POST' 'PUT' 'DELETE'
 * @param {String} url the url to make a request to
 * @param {String|Object} data some content to be sent with the request.
 *                        Only valid if method is POST or PUT.
 * @param {Object} [headers] the http request headers to send
 */
function streamingHttp(fire, on, xhr, method, url, data, headers) {

   var numberOfCharsAlreadyGivenToCallback = 0;

   // When an ABORTING message is put on the event bus abort
   // the ajax request
   on( ABORTING, function(){

      // if we keep the onreadystatechange while aborting the XHR gives
      // a callback like a successful call so first remove this listener
      // by assigning null:
      xhr.onreadystatechange = null;

      xhr.abort();
   });

   /** Given a value from the user to send as the request body, return in
    *  a form that is suitable to sending over the wire. Returns either a
    *  string, or null.
    */
   function validatedRequestBody( body ) {
      if( !body )
         return null;

      return isString(body)? body: JSON.stringify(body);
   }

   /**
    * Handle input from the underlying xhr: either a state change,
    * the progress event or the request being complete.
    */
   function handleProgress() {

      var textSoFar = xhr.responseText,
          newText = textSoFar.substr(numberOfCharsAlreadyGivenToCallback);


      /* Raise the event for new text.

         On older browsers, the new text is the whole response.
         On newer/better ones, the fragment part that we got since
         last progress. */

      if( newText ) {
         fire( NEW_CONTENT, newText );
      }

      numberOfCharsAlreadyGivenToCallback = len(textSoFar);
   }


   if('onprogress' in xhr){  // detect browser support for progressive delivery
      xhr.onprogress = handleProgress;
   }

   xhr.onreadystatechange = function() {

      if(xhr.readyState == 4 ) {

         // is this a 2xx http code?
         var sucessful = String(xhr.status)[0] == 2;

         if( sucessful ) {
            // In Chrome 29 (not 28) no onprogress is fired when a response
            // is complete before the onload. We need to always do handleInput
            // in case we get the load but have not had a final progress event.
            // This looks like a bug and may change in future but let's take
            // the safest approach and assume we might not have received a
            // progress event for each part of the response
            handleProgress();

            fire( END_OF_CONTENT );
         } else {

            fire( ERROR_EVENT, xhr.status );
         }
      }
   };

   try{

      xhr.open(method, url, true);

      for( var headerName in headers ){
         xhr.setRequestHeader(headerName, headers[headerName]);
      }

      xhr.send(validatedRequestBody(data));

   } catch( e ) {
      // To keep a consistent interface with Node, we can't fire an event here.
      // Node's streaming http adaptor receives the error as an asynchronous
      // event rather than as an exception. If we fired now, the Oboe user
      // has had no chance to add a .fail listener so there is no way
      // the event could be useful. For both these reasons defer the
      // firing to the next JS frame.
      window.setTimeout(partialComplete(fire, ERROR_EVENT, e), 0);
   }
}

var jsonPathSyntax = (function() {

   var

   /**
    * Export a regular expression as a simple function by exposing just
    * the Regex#exec. This allows regex tests to be used under the same
    * interface as differently implemented tests, or for a user of the
    * tests to not concern themselves with their implementation as regular
    * expressions.
    *
    * This could also be expressed point-free as:
    *   Function.prototype.bind.bind(RegExp.prototype.exec),
    *
    * But that's far too confusing! (and not even smaller once minified
    * and gzipped)
    */
       regexDescriptor = function regexDescriptor(regex) {
            return regex.exec.bind(regex);
       }

   /**
    * Join several regular expressions and express as a function.
    * This allows the token patterns to reuse component regular expressions
    * instead of being expressed in full using huge and confusing regular
    * expressions.
    */
   ,   jsonPathClause = varArgs(function( componentRegexes ) {

            // The regular expressions all start with ^ because we
            // only want to find matches at the start of the
            // JSONPath fragment we are inspecting
            componentRegexes.unshift(/^/);

            return   regexDescriptor(
                        RegExp(
                           componentRegexes.map(attr('source')).join('')
                        )
                     );
       })

   ,   possiblyCapturing =           /(\$?)/
   ,   namedNode =                   /([\w-_]+|\*)/
   ,   namePlaceholder =             /()/
   ,   nodeInArrayNotation =         /\["([^"]+)"\]/
   ,   numberedNodeInArrayNotation = /\[(\d+|\*)\]/
   ,   fieldList =                      /{([\w ]*?)}/
   ,   optionalFieldList =           /(?:{([\w ]*?)})?/


       //   foo or *
   ,   jsonPathNamedNodeInObjectNotation   = jsonPathClause(
                                                possiblyCapturing,
                                                namedNode,
                                                optionalFieldList
                                             )

       //   ["foo"]
   ,   jsonPathNamedNodeInArrayNotation    = jsonPathClause(
                                                possiblyCapturing,
                                                nodeInArrayNotation,
                                                optionalFieldList
                                             )

       //   [2] or [*]
   ,   jsonPathNumberedNodeInArrayNotation = jsonPathClause(
                                                possiblyCapturing,
                                                numberedNodeInArrayNotation,
                                                optionalFieldList
                                             )

       //   {a b c}
   ,   jsonPathPureDuckTyping              = jsonPathClause(
                                                possiblyCapturing,
                                                namePlaceholder,
                                                fieldList
                                             )

       //   ..
   ,   jsonPathDoubleDot                   = jsonPathClause(/\.\./)

       //   .
   ,   jsonPathDot                         = jsonPathClause(/\./)

       //   !
   ,   jsonPathBang                        = jsonPathClause(
                                                possiblyCapturing,
                                                /!/
                                             )

       //   nada!
   ,   emptyString                         = jsonPathClause(/$/)

   ;


   /* We export only a single function. When called, this function injects
      into another function the descriptors from above.
    */
   return function (fn){
      return fn(
         lazyUnion(
            jsonPathNamedNodeInObjectNotation
         ,  jsonPathNamedNodeInArrayNotation
         ,  jsonPathNumberedNodeInArrayNotation
         ,  jsonPathPureDuckTyping
         )
      ,  jsonPathDoubleDot
      ,  jsonPathDot
      ,  jsonPathBang
      ,  emptyString
      );
   };

}());
/**
 * This file provides various listeners which can be used to build up
 * a changing ascent based on the callbacks provided by Clarinet. It listens
 * to the low-level events from Clarinet and fires higher-level ones.
 *
 * The building up is stateless so to track a JSON file
 * clarinetListenerAdaptor.js is required to store the ascent state
 * between calls.
 */


var keyOf = attr('key');
var nodeOf = attr('node');


/**
 * A special value to use in the path list to represent the path 'to' a root
 * object (which doesn't really have any path). This prevents the need for
 * special-casing detection of the root object and allows it to be treated
 * like any other object. We might think of this as being similar to the
 * 'unnamed root' domain ".", eg if I go to
 * http://en.wikipedia.org./wiki/En/Main_page the dot after 'org' deliminates
 * the unnamed root of the DNS.
 *
 * This is kept as an object to take advantage that in Javascript's OO objects
 * are guaranteed to be distinct, therefore no other object can possibly clash
 * with this one. Strings, numbers etc provide no such guarantee.
 **/
var ROOT_PATH = {};


/**
 * Create a new set of handlers for clarinet's events, bound to the fire
 * function given.
 */
function incrementalContentBuilder( fire) {


   function arrayIndicesAreKeys( possiblyInconsistentAscent, newDeepestNode) {

      /* for values in arrays we aren't pre-warned of the coming paths
         (Clarinet gives no call to onkey like it does for values in objects)
         so if we are in an array we need to create this path ourselves. The
         key will be len(parentNode) because array keys are always sequential
         numbers. */

      var parentNode = nodeOf( head( possiblyInconsistentAscent));

      return      isOfType( Array, parentNode)
               ?
                  pathFound(  possiblyInconsistentAscent,
                              len(parentNode),
                              newDeepestNode
                  )
               :
                  // nothing needed, return unchanged
                  possiblyInconsistentAscent
               ;
   }

   function nodeFound( ascent, newDeepestNode ) {

      if( !ascent ) {
         // we discovered the root node,
         fire( ROOT_FOUND, newDeepestNode);

         return pathFound( ascent, ROOT_PATH, newDeepestNode);
      }

      // we discovered a non-root node

      var arrayConsistentAscent  = arrayIndicesAreKeys( ascent, newDeepestNode),
          ancestorBranches       = tail( arrayConsistentAscent),
          previouslyUnmappedName = keyOf( head( arrayConsistentAscent));

      appendBuiltContent(
         ancestorBranches,
         previouslyUnmappedName,
         newDeepestNode
      );

      return cons(
               namedNode( previouslyUnmappedName, newDeepestNode ),
               ancestorBranches
      );
   }


   /**
    * Add a new value to the object we are building up to represent the
    * parsed JSON
    */
   function appendBuiltContent( ancestorBranches, key, node ){

      nodeOf( head( ancestorBranches))[key] = node;
   }

   /**
    * Get a new key->node mapping
    *
    * @param {String|Number} key
    * @param {Object|Array|String|Number|null} node a value found in the json
    */
   function namedNode(key, node) {
      return {key:key, node:node};
   }

   /**
    * For when we find a new key in the json.
    *
    * @param {String|Number|Object} newDeepestName the key. If we are in an
    *    array will be a number, otherwise a string. May take the special
    *    value ROOT_PATH if the root node has just been found
    *
    * @param {String|Number|Object|Array|Null|undefined} [maybeNewDeepestNode]
    *    usually this won't be known so can be undefined. Can't use null
    *    to represent unknown because null is a valid value in JSON
    **/
   function pathFound(ascent, newDeepestName, maybeNewDeepestNode) {

      if( ascent ) { // if not root

         // If we have the key but (unless adding to an array) no known value
         // yet. Put that key in the output but against no defined value:
         appendBuiltContent( ascent, newDeepestName, maybeNewDeepestNode );
      }

      var ascentWithNewPath = cons(
                                 namedNode( newDeepestName,
                                            maybeNewDeepestNode),
                                 ascent
                              );

      fire( PATH_FOUND, ascentWithNewPath);

      return ascentWithNewPath;
   }


   /**
    * For when the current node ends
    */
   function curNodeFinished( ascent ) {

      fire( NODE_FOUND, ascent);

      // pop the complete node and its path off the list:
      return tail( ascent);
   }

   return {

      openobject : function (ascent, firstKey) {

         var ascentAfterNodeFound = nodeFound(ascent, {});

         /* It is a perculiarity of Clarinet that for non-empty objects it
            gives the first key with the openobject event instead of
            in a subsequent key event.

            firstKey could be the empty string in a JSON object like
            {'':'foo'} which is technically valid.

            So can't check with !firstKey, have to see if has any
            defined value. */
         return defined(firstKey)
         ?
            /* We know the first key of the newly parsed object. Notify that
               path has been found but don't put firstKey permanently onto
               pathList yet because we haven't identified what is at that key
               yet. Give null as the value because we haven't seen that far
               into the json yet */
            pathFound(ascentAfterNodeFound, firstKey)
         :
            ascentAfterNodeFound
         ;
      },

      openarray: function (ascent) {
         return nodeFound(ascent, []);
      },

      // called by Clarinet when keys are found in objects
      key: pathFound,

      /* Emitted by Clarinet when primitive values are found, ie Strings,
         Numbers, and null.
         Because these are always leaves in the JSON, we find and finish the
         node in one step, expressed as functional composition: */
      value: compose( curNodeFinished, nodeFound ),

      // we make no distinction in how we handle object and arrays closing.
      // For both, interpret as the end of the current node.
      closeobject: curNodeFinished,
      closearray: curNodeFinished
   };
}
/**
 * The jsonPath evaluator compiler used for Oboe.js.
 *
 * One function is exposed. This function takes a String JSONPath spec and
 * returns a function to test candidate ascents for matches.
 *
 *  String jsonPath -> (List ascent) -> Boolean|Object
 *
 * This file is coded in a pure functional style. That is, no function has
 * side effects, every function evaluates to the same value for the same
 * arguments and no variables are reassigned.
 */
// the call to jsonPathSyntax injects the token syntaxes that are needed
// inside the compiler
var jsonPathCompiler = jsonPathSyntax(function (pathNodeSyntax,
                                                doubleDotSyntax,
                                                dotSyntax,
                                                bangSyntax,
                                                emptySyntax ) {

   var CAPTURING_INDEX = 1;
   var NAME_INDEX = 2;
   var FIELD_LIST_INDEX = 3;

   var headKey = compose(keyOf, head);

   /**
    * Create an evaluator function for a named path node, expressed in the
    * JSONPath like:
    *    foo
    *    ["bar"]
    *    [2]
    */
   function nameClause(previousExpr, detection ) {

      var name = detection[NAME_INDEX],

          matchesName = ( !name || name == '*' )
                           ?  always
                           :  function(ascent){return headKey(ascent) == name};


      return lazyIntersection(matchesName, previousExpr);
   }

   /**
    * Create an evaluator function for a a duck-typed node, expressed like:
    *
    *    {spin, taste, colour}
    *    .particle{spin, taste, colour}
    *    *{spin, taste, colour}
    */
   function duckTypeClause(previousExpr, detection) {

      var fieldListStr = detection[FIELD_LIST_INDEX];

      if (!fieldListStr)
         return previousExpr; // don't wrap at all, return given expr as-is

      var hasAllrequiredFields = partialComplete(
                                    hasAllProperties,
                                    arrayAsList(fieldListStr.split(/\W+/))
                                 ),

          isMatch =  compose(
                        hasAllrequiredFields,
                        nodeOf,
                        head
                     );

      return lazyIntersection(isMatch, previousExpr);
   }

   /**
    * Expression for $, returns the evaluator function
    */
   function capture( previousExpr, detection ) {

      // extract meaning from the detection
      var capturing = !!detection[CAPTURING_INDEX];

      if (!capturing)
         return previousExpr; // don't wrap at all, return given expr as-is

      return lazyIntersection(previousExpr, head);

   }

   /**
    * Create an evaluator function that moves onto the next item on the
    * lists. This function is the place where the logic to move up a
    * level in the ascent exists.
    *
    * Eg, for JSONPath ".foo" we need skip1(nameClause(always, [,'foo']))
    */
   function skip1(previousExpr) {


      if( previousExpr == always ) {
         /* If there is no previous expression this consume command
            is at the start of the jsonPath.
            Since JSONPath specifies what we'd like to find but not
            necessarily everything leading down to it, when running
            out of JSONPath to check against we default to true */
         return always;
      }

      /** return true if the ascent we have contains only the JSON root,
       *  false otherwise
       */
      function notAtRoot(ascent){
         return headKey(ascent) != ROOT_PATH;
      }

      return lazyIntersection(
               /* If we're already at the root but there are more
                  expressions to satisfy, can't consume any more. No match.

                  This check is why none of the other exprs have to be able
                  to handle empty lists; skip1 is the only evaluator that
                  moves onto the next token and it refuses to do so once it
                  reaches the last item in the list. */
               notAtRoot,

               /* We are not at the root of the ascent yet.
                  Move to the next level of the ascent by handing only
                  the tail to the previous expression */
               compose(previousExpr, tail)
      );

   }

   /**
    * Create an evaluator function for the .. (double dot) token. Consumes
    * zero or more levels of the ascent, the fewest that are required to find
    * a match when given to previousExpr.
    */
   function skipMany(previousExpr) {

      if( previousExpr == always ) {
         /* If there is no previous expression this consume command
            is at the start of the jsonPath.
            Since JSONPath specifies what we'd like to find but not
            necessarily everything leading down to it, when running
            out of JSONPath to check against we default to true */
         return always;
      }

      var
          // In JSONPath .. is equivalent to !.. so if .. reaches the root
          // the match has succeeded. Ie, we might write ..foo or !..foo
          // and both should match identically.
          terminalCaseWhenArrivingAtRoot = rootExpr(),
          terminalCaseWhenPreviousExpressionIsSatisfied = previousExpr,
          recursiveCase = skip1(skipManyInner),

          cases = lazyUnion(
                     terminalCaseWhenArrivingAtRoot
                  ,  terminalCaseWhenPreviousExpressionIsSatisfied
                  ,  recursiveCase
                  );

      function skipManyInner(ascent) {

         if( !ascent ) {
            // have gone past the start, not a match:
            return false;
         }

         return cases(ascent);
      }

      return skipManyInner;
   }

   /**
    * Generate an evaluator for ! - matches only the root element of the json
    * and ignores any previous expressions since nothing may precede !.
    */
   function rootExpr() {

      return function(ascent){
         return headKey(ascent) == ROOT_PATH;
      };
   }

   /**
    * Generate a statement wrapper to sit around the outermost
    * clause evaluator.
    *
    * Handles the case where the capturing is implicit because the JSONPath
    * did not contain a '$' by returning the last node.
    */
   function statementExpr(lastClause) {

      return function(ascent) {

         // kick off the evaluation by passing through to the last clause
         var exprMatch = lastClause(ascent);

         return exprMatch === true ? head(ascent) : exprMatch;
      };
   }

   /**
    * For when a token has been found in the JSONPath input.
    * Compiles the parser for that token and returns in combination with the
    * parser already generated.
    *
    * @param {Function} exprs  a list of the clause evaluator generators for
    *                          the token that was found
    * @param {Function} parserGeneratedSoFar the parser already found
    * @param {Array} detection the match given by the regex engine when
    *                          the feature was found
    */
   function expressionsReader( exprs, parserGeneratedSoFar, detection ) {

      // if exprs is zero-length foldR will pass back the
      // parserGeneratedSoFar as-is so we don't need to treat
      // this as a special case

      return   foldR(
                  function( parserGeneratedSoFar, expr ){

                     return expr(parserGeneratedSoFar, detection);
                  },
                  parserGeneratedSoFar,
                  exprs
               );

   }

   /**
    *  If jsonPath matches the given detector function, creates a function which
    *  evaluates against every clause in the clauseEvaluatorGenerators. The
    *  created function is propagated to the onSuccess function, along with
    *  the remaining unparsed JSONPath substring.
    *
    *  The intended use is to create a clauseMatcher by filling in
    *  the first two arguments, thus providing a function that knows
    *  some syntax to match and what kind of generator to create if it
    *  finds it. The parameter list once completed is:
    *
    *    (jsonPath, parserGeneratedSoFar, onSuccess)
    *
    *  onSuccess may be compileJsonPathToFunction, to recursively continue
    *  parsing after finding a match or returnFoundParser to stop here.
    */
   function generateClauseReaderIfTokenFound (

                        tokenDetector, clauseEvaluatorGenerators,

                        jsonPath, parserGeneratedSoFar, onSuccess) {

      var detected = tokenDetector(jsonPath);

      if(detected) {
         var compiledParser = expressionsReader(
                                 clauseEvaluatorGenerators,
                                 parserGeneratedSoFar,
                                 detected
                              ),

             remainingUnparsedJsonPath = jsonPath.substr(len(detected[0]));

         return onSuccess(remainingUnparsedJsonPath, compiledParser);
      }
   }

   /**
    * Partially completes generateClauseReaderIfTokenFound above.
    */
   function clauseMatcher(tokenDetector, exprs) {

      return   partialComplete(
                  generateClauseReaderIfTokenFound,
                  tokenDetector,
                  exprs
               );
   }

   /**
    * clauseForJsonPath is a function which attempts to match against
    * several clause matchers in order until one matches. If non match the
    * jsonPath expression is invalid and an error is thrown.
    *
    * The parameter list is the same as a single clauseMatcher:
    *
    *    (jsonPath, parserGeneratedSoFar, onSuccess)
    */
   var clauseForJsonPath = lazyUnion(

      clauseMatcher(pathNodeSyntax   , list( capture,
                                             duckTypeClause,
                                             nameClause,
                                             skip1 ))

   ,  clauseMatcher(doubleDotSyntax  , list( skipMany))

       // dot is a separator only (like whitespace in other languages) but
       // rather than make it a special case, use an empty list of
       // expressions when this token is found
   ,  clauseMatcher(dotSyntax        , list() )

   ,  clauseMatcher(bangSyntax       , list( capture,
                                             rootExpr))

   ,  clauseMatcher(emptySyntax      , list( statementExpr))

   ,  function (jsonPath) {
         throw Error('"' + jsonPath + '" could not be tokenised')
      }
   );


   /**
    * One of two possible values for the onSuccess argument of
    * generateClauseReaderIfTokenFound.
    *
    * When this function is used, generateClauseReaderIfTokenFound simply
    * returns the compiledParser that it made, regardless of if there is
    * any remaining jsonPath to be compiled.
    */
   function returnFoundParser(_remainingJsonPath, compiledParser){
      return compiledParser
   }

   /**
    * Recursively compile a JSONPath expression.
    *
    * This function serves as one of two possible values for the onSuccess
    * argument of generateClauseReaderIfTokenFound, meaning continue to
    * recursively compile. Otherwise, returnFoundParser is given and
    * compilation terminates.
    */
   function compileJsonPathToFunction( uncompiledJsonPath,
                                       parserGeneratedSoFar ) {

      /**
       * On finding a match, if there is remaining text to be compiled
       * we want to either continue parsing using a recursive call to
       * compileJsonPathToFunction. Otherwise, we want to stop and return
       * the parser that we have found so far.
       */
      var onFind =      uncompiledJsonPath
                     ?  compileJsonPathToFunction
                     :  returnFoundParser;

      return   clauseForJsonPath(
                  uncompiledJsonPath,
                  parserGeneratedSoFar,
                  onFind
               );
   }

   /**
    * This is the function that we expose to the rest of the library.
    */
   return function(jsonPath){

      try {
         // Kick off the recursive parsing of the jsonPath
         return compileJsonPathToFunction(jsonPath, always);

      } catch( e ) {
         throw Error( 'Could not compile "' + jsonPath +
                      '" because ' + e.message
         );
      }
   }

});

/**
 * Isn't this the cutest little pub-sub you've ever seen?
 *
 * Does not allow unsubscription because is never needed inside Oboe.
 * Instead, when an Oboe instance is finished the whole of it should be
 * available for GC'ing.
 */
function pubSub(){

   var listeners = {};

   return {

      on:function( eventId, fn ) {

         listeners[eventId] = cons(fn, listeners[eventId]);

         return this; // chaining
      },

      fire:function ( eventId, event ) {

         each(
            partialComplete( apply, [event || undefined] ),
            listeners[eventId]
         );
      }
   };
}
/**
 * This file declares some constants to use as names for event types.
 */

var // NODE_FOUND, PATH_FOUND and ERROR_EVENT feature
    // in the public API via .on('node', ...) or .on('path', ...)
    // so these events are strings
    NODE_FOUND    = 'node',
    PATH_FOUND    = 'path',

    // these events are never exported so are kept as
    // the smallest possible representation, numbers:
    _S = 0,
    ERROR_EVENT   = _S++,
    ROOT_FOUND    = _S++,
    NEW_CONTENT = _S++,
    END_OF_CONTENT = _S++,
    ABORTING = _S++;
/**
 * This file implements a light-touch central controller for an instance
 * of Oboe which provides the methods used for interacting with the instance
 * from the calling app.
 */


function instanceController(fire, on, clarinetParser, contentBuilderHandlers) {

   var oboeApi, rootNode;

   // when the root node is found grap a reference to it for later
   on(ROOT_FOUND, function(root) {
      rootNode = root;
   });

   on(NEW_CONTENT,
      function (nextDrip) {
         // callback for when a bit more data arrives from the streaming XHR

         try {

            clarinetParser.write(nextDrip);
         } catch(e) {
            /* we don't have to do anything here because we always assign
               a .onerror to clarinet which will have already been called
               by the time this exception is thrown. */
         }
      }
   );

   /* At the end of the http content close the clarinet parser.
      This will provide an error if the total content provided was not
      valid json, ie if not all arrays, objects and Strings closed properly */
   on(END_OF_CONTENT, clarinetParser.close.bind(clarinetParser));


   /* If we abort this Oboe's request stop listening to the clarinet parser.
      This prevents more tokens being found after we abort in the case where
      we aborted during processing of an already filled buffer. */
   on( ABORTING, function() {
      clarinetListenerAdaptor(clarinetParser, {});
   });

   clarinetListenerAdaptor(clarinetParser, contentBuilderHandlers);

   // react to errors by putting them on the event bus
   clarinetParser.onerror = function(e) {
      fire(ERROR_EVENT, e);

      // note: don't close clarinet here because if it was not expecting
      // end of the json it will throw an error
   };

   function addPathOrNodeCallback( eventId, pattern, callback ) {

      var matchesJsonPath = jsonPathCompiler( pattern );

      // Add a new callback adaptor to the eventBus.
      // This listener first checks that he pattern matches then if it does,
      // passes it onto the callback.
      on( eventId, function( ascent ){

         var maybeMatchingMapping = matchesJsonPath( ascent );

         /* Possible values for maybeMatchingMapping are now:

            false:
               we did not match

            an object/array/string/number/null:
               we matched and have the node that matched.
               Because nulls are valid json values this can be null.

            undefined:
               we matched but don't have the matching node yet.
               ie, we know there is an upcoming node that matches but we
               can't say anything else about it.
         */
         if( maybeMatchingMapping !== false ) {

            notifyCallback(callback, maybeMatchingMapping, ascent);
         }
      });
   }

   function notifyCallback(callback, matchingMapping, ascent) {
      /*
         We're now calling back to outside of oboe where the Lisp-style
         lists that we are using internally will not be recognised
         so convert to standard arrays.

         Also, reverse the order because it is more common to list paths
         "root to leaf" than "leaf to root"
      */

      var descent     = reverseList(ascent),

          // To make a path, strip off the last item which is the special
          // ROOT_PATH token for the 'path' to the root node
          path       = listAsArray(tail(map(keyOf,descent))),
          ancestors  = listAsArray(map(nodeOf, descent));

      try{

         callback( nodeOf(matchingMapping), path, ancestors );
      }catch(e)  {

         // An error occured during the callback, publish it on the event bus
         fire(ERROR_EVENT, e);
      }
   }

   /**
    * Add several listeners at a time, from a map
    */
   function addListenersMap(eventId, listenerMap) {

      for( var pattern in listenerMap ) {
         addPathOrNodeCallback(eventId, pattern, listenerMap[pattern]);
      }
   }

   /**
    * implementation behind .onPath() and .onNode()
    */
   function addNodeOrPathListenerApi( eventId, jsonPathOrListenerMap,
                                      callback, callbackContext ){

      if( isString(jsonPathOrListenerMap) ) {
         addPathOrNodeCallback(
            eventId,
            jsonPathOrListenerMap,
            callback.bind(callbackContext||oboeApi)
         );
      } else {
         addListenersMap(eventId, jsonPathOrListenerMap);
      }

      return this; // chaining
   }

   /**
    * Construct and return the public API of the Oboe instance to be
    * returned to the calling application
    */
   return oboeApi = {
      path  :  partialComplete(addNodeOrPathListenerApi, PATH_FOUND),
      node  :  partialComplete(addNodeOrPathListenerApi, NODE_FOUND),
      on    :  addNodeOrPathListenerApi,
      fail  :  partialComplete(on, ERROR_EVENT),
      done  :  partialComplete(addNodeOrPathListenerApi, NODE_FOUND, '!'),
      abort :  partialComplete(fire, ABORTING),
      root  :  function rootNodeFunctor() {
                  return rootNode;
               }
   };
}
/**
 * This file sits just behind the API which is used to attain a new
 * Oboe instance. It creates the new components that are required
 * and introduces them to each other.
 */

function wire (httpMethodName, contentSource, body, headers){

   var eventBus = pubSub();

   streamingHttp( eventBus.fire, eventBus.on,
                  httpTransport(),
                  httpMethodName, contentSource, body, headers );

   return instanceController(
               eventBus.fire, eventBus.on,
               clarinet.parser(),
               incrementalContentBuilder(eventBus.fire)
   );
}

// export public API
var oboe = apiMethod('GET');
oboe.doGet    = oboe;
oboe.doDelete = apiMethod('DELETE');
oboe.doPost   = apiMethod('POST', true);
oboe.doPut    = apiMethod('PUT', true);

function apiMethod(httpMethodName, mayHaveRequestBody) {

   return function(firstArg) {

      if (firstArg.url) {

         // method signature is:
         //    .doMethod({url:u, body:b, complete:c, headers:{...}})

         return wire(
             httpMethodName,
             firstArg.url,
             firstArg.body,
             firstArg.headers
         );
      } else {

         // parameters specified as arguments
         //
         //  if (mayHaveContext == true) method signature is:
         //     .doMethod( url, content )
         //
         //  else it is:
         //     .doMethod( url )
         //
         return wire(
             httpMethodName,
             firstArg, // url
             mayHaveRequestBody && arguments[1]         // body
         );
      }
   };
}

;return oboe;})(window, Object, Array, Error);