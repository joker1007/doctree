= Marshal�ե����ޥå�

2002-04-04 �ɥ�եȤΥɥ�եȤΥɥ�եȤ�....

* �ե����ޥåȥС������ 4.8 (1.8����)�򸵤˵���

    # 2003-05-02 ���ߤΥե����ޥåȥС������ϰʲ�
    p Marshal.dump(Object.new).unpack("cc").join(".")
        => ruby 1.6.0 (2000-09-19) [i586-linux]
           "4.4"
        => ruby 1.6.1 (2000-09-27) [i586-linux]
           "4.4"
        => ruby 1.6.2 (2000-12-25) [i586-linux]
           "4.5"
        => ruby 1.6.3 (2001-03-19) [i586-linux]
           "4.5"
        => ruby 1.6.4 (2001-06-04) [i586-linux]
           "4.5"
        => ruby 1.6.5 (2001-09-19) [i586-linux]
           "4.6"
        => ruby 1.6.6 (2001-12-26) [i586-linux]
           "4.6"
        => ruby 1.6.7 (2002-03-01) [i586-linux]
           "4.6"
        => ruby 1.6.7 (2002-09-06) [i586-linux]
           "4.6"
        => ruby 1.7.3 (2002-09-06) [i586-linux]
           "4.7"
        => ruby 1.7.3 (2002-09-20) [i586-linux]
           "4.8"
        => ruby 1.8.0 (2003-08-03) [i586-linux]
           "4.8"

* ���С������ˤĤ��Ƥ⿨��롣�ߴ����ˤĤ��Ƥ�
* Ruby �� Marshal �ΥХ��ˤĤ��Ƥ⤳���ǿ����(?)

: nil
: true
: false
  ���줾�졢'0', 'T', 'F'

    p Marshal.dump(nil).unpack("x2 a*")
    # => ["0"]

  ���󥹥����ѿ������ꤷ�Ƥ� dump ����ޤ���

    class NilClass
      attr_accessor :foo
    end
    nil.foo = 1
    p nil.foo                           # => 1
    p Marshal.dump(nil).unpack("x2 a*") # => ["0"]

: Fixnum

  'i' ��³���� Fixnum ��ɽ���ǡ�����¤��³���ޤ���

  ������ʬ��ɽ������(����� Fixnum �˸¤餺¾�βս�Ǥ�Ȥ��ޤ�)�ϡ�
  ���� n ���Ф���

  ���� 1:
      n == 0:       0
      0 < n < 123:  n + 5
      -124 < n < 0: n - 5

  �Ȥ�������(1 byte)���Ǽ���ޤ���5 ��­������������ꤹ��Τϲ�����
  �����Ȥζ��̤Τ���Ǥ���

  ��:

    p Marshal.dump(-1).unpack("x2 a*") # => "i\372"
    p Marshal.dump(0).unpack("x2 a*")  # => "i\000"
    p Marshal.dump(1).unpack("x2 a*")  # => "i\006"
    p Marshal.dump(2).unpack("x2 a*")  # => "i\a"   ("i\007")

  ���� 1 ���ϰϤ�Ķ������� N ���Ф��Ƥϡ��ʲ��η����ˤʤ�ޤ���

  ���� 2:

    | len | n1 | n2 | n3 | n4 |
     <-1-> <-     len       ->
     byte        bytes

  len ���ͤ� -4 �� -1, 1 �� 4 �ǡ����ȸ�³�Υǡ����� n1 �� n|len| ��
  �Ǥ��뤳�Ȥ򼨤��ޤ���

    # ��äȤ��ޤ�����...
    def foo(len, n1, n2 = 0, n3 = 0, n4 = 0)

        case len
        when -3;           n4 = 255
        when -2;      n3 = n4 = 255
        when -1; n2 = n3 = n4 = 255
        end

        n = (0xffffff00 | n1) &
            (0xffff00ff | n2 * 0x100) &
            (0xff00ffff | n3 * 0x10000) &
            (0x00ffffff | n4 * 0x1000000)
        # p "%x" % n
        n = -((n ^ 0xffff_ffff) + 1) if len < 0
        n
    end

    p Marshal.dump(-125).unpack("x2 acC*") # => ["i", -1, 131]
    p foo(-1, 131)
    p Marshal.dump(-255).unpack("x2 acC*") # => ["i", -1, 1]
    p foo(-1, 1)
    p Marshal.dump(-256).unpack("x2 acC*") # => ["i", -1, 0]
    p foo(-1, 0)
    p Marshal.dump(-257).unpack("x2 acC*") # => ["i", -2, 255, 254]
    p foo(-2, 255, 254)
    p Marshal.dump(124).unpack("x2 acC*") # => ["i", 1, 124]
    p foo(1, 124)
    p Marshal.dump(256).unpack("x2 acC*") # => ["i", 2, 0, 1]
    p foo(2, 0, 1)

  ���󥹥����ѿ������ꤷ�Ƥ� dump ����ޤ���

    class Fixnum
      attr_accessor :foo
    end
    99.foo = 1
    p 99.foo                           # => 1
    p 999.foo                          # => nil
    p Marshal.dump(99).unpack("x2 ac") # => ["i", 104]

: instance of the user class

  'C': String, Regexp, Array, Hash �Υ��֥��饹�Υ��󥹥����ѿ�

    | 'C' | ���饹̾(Symbol)�� dump | �ƥ��饹�Υ��󥹥��󥹤� dump |

  �� 1:

    class Foo < String # (or Regexp, Array, Hash)
    end
    p Marshal.dump(Foo.new("foo")).unpack("x2 a a c a3 aca*")
    # => ["C", ":", 8, "Foo", "\"", 8, "foo"]
                              ^^^ (or '/', '[', '{')

  �� 2: ���󥹥����ѿ�����([[unknown:Marshal�ե����ޥå�/instance variable]] ����)

    class Foo < String # (or Regexp, Array, Hash)
      def initialize(obj)
        @foo = obj
        super(obj)
      end
    end
    p Marshal.dump(Foo.new("foo")).unpack("x2 a a a c a3 aca3 caca4 aca*")
    # => ["I", "C", ":", 8, "Foo", "\"", 8, "foo", 6, ":", 9, "@foo", "\"", 8, "foo"]


  �嵭�ʳ��Ǥϡ�'o' �ˤʤ롣����ϡ�������������¤���ۤʤ뤿��
  ([[unknown:Marshal�ե����ޥå�/Object]] ����)

  ��:
    class Foo
    end
    p Marshal.dump(Foo.new).unpack("x2 a a c a*")
    # => ["o", ":", 8, "Foo\000"]

  'u'

  _dump��_load ��������Ƥ���� 'u' �ˤʤ롣
  ���󥹥����ѿ��� dump ����ʤ��ʤ�Τǡ�_dump/_load ���б�����ɬ��
  �����롣

    | 'u' | ���饹̾(Symbol)�� dump | _dump �η�̤�Ĺ��(Fixnum����) |
    | _dump ���֤��� |

  ��:
    class Foo
      def self._load
      end
      def _dump(obj)
        "hogehoge"
      end
    end
    p Marshal.dump(Foo.new).unpack("x2 a aca3 c a*")
    # => ["u", ":", 8, "Foo", 13, "hogehoge"]

  'U'  ((<ruby 1.8 feature>))

  marshal_dump��marshal_load ��������Ƥ���� 'U' �ˤʤ롣
  ���󥹥����ѿ��� dump ����ʤ��ʤ�Τǡ�marshal_dump/marshal_load
  ���б�����ɬ�פ����롣

    | 'U' | ���饹̾(Symbol)�� dump | marshal_dump �᥽�åɤ�����ͤ� dump |

  ��:
    class Foo
      def marshal_dump
        "hogehoge"
      end
      def marshal_load(obj)
      end
    end
    p Marshal.dump(Foo.new).unpack("x2 a aca3 a c a*")

    # => ["U", ":", 8, "Foo", "\"", 13, "hogehoge"]

: Object

  'o'

    | 'o' | ���饹̾(Symbol)�� dump | ���󥹥����ѿ��ο�(Fixnum����) |
    | ���󥹥����ѿ�̾(Symbol) ��dump(1) | ��(1) |
              :
              :
    | ���󥹥����ѿ�̾(Symbol) ��dump(n) | ��(n) |

  �� 1:
    p Marshal.dump(Object.new).unpack("x2 a a c a*")
    # => ["o", ":", 11, "Object\000"]

  �� 2: ���󥹥����ѿ�����
    class Foo
      def initialize
        @foo = "foo"
        @bar = "bar"
      end
    end
    p Marshal.dump(Foo.new).unpack("x2 a a c a3 c aca4 aca3 aca4 aca3")
    # => ["o", ":", 8, "Foo", 7,
          ":", 9, "@bar", "\"", 8, "bar",
          ":", 9, "@foo", "\"", 8, "foo"]

: Float

  'f'

   | 'f' | �������Ĺ��(Fixnum����) | "%.16g" ��ʸ���� |

  ��:
    p Marshal.dump(Math::PI).unpack("x2 a c a*")
    # => ["f", 22, "3.141592653589793"]

    p Marshal.dump(0.0/0).unpack("x2 a c a*")  # => ["f", 8, "nan"]
    p Marshal.dump(1.0/0).unpack("x2 a c a*")  # => ["f", 8, "inf"]
    p Marshal.dump(-1.0/0).unpack("x2 a c a*") # => ["f", 9, "-inf"]
    p Marshal.dump(-0.0).unpack("x2 a c a*")   # => ["f", 9, "-0"]

  ((-((<ruby 1.7 feature>)): version 1.6 �Ǥϡ�nan �ʤɤν��Ϥ�
  [[man:sprintf(3)]] �˰�¸���Ƥ��롣�ɤ߹��ߤϸ��ߤΤȤ�
  �� "nan", "inf", "-inf" �ʳ��� [[man:strtod(3)]] �˰�¸
  ���Ƥ��롣-> 1.7 �Ǥϡ�sprintf(3)/strtod(3) �ؤΰ�¸�Ϥʤ��ʤä�-))

: Bignum

  'l'

    | 'l' | '+'/'-' | short�θĿ�(Fixnum����) | ... |

  ��:
    p Marshal.dump(2**32).unpack("x2 a a c a*")
    # => ["l", "+", 8, "\000\000\000\000\001\000"]

    # => ["l", "+", 8, "\000\000\001\000"]  <- BUG: ruby version 1.6.3

: String

  '"'
    | '"' | Ĺ��(Fixnum����) | ʸ���� |

  ��:
    p Marshal.dump("hogehoge").unpack("x2 a c a*")
    # => ["\"", 13, "hogehoge"]

: Regexp

  '/'

    | '/' | Ĺ��(Fixnum����) | ������ʸ���� | ���ץ���� |

  ���ץ����ϡ�[[m:Regexp#options]]�η�� + ���������ɤΥե饰�͡�

  ��:
    p Marshal.dump(/(hoge)*/).unpack("x2 a c a7 c")
    # => ["/", 12, "(hoge)*", 0]

    p Marshal.dump(/hogehoge/m).unpack("x2 a c a8 c")
    # => ["/", 13, "hogehoge", 4]

    p Marshal.dump(/hogehoge/e).unpack("x2 a c a8 c")

    # => ["/", 13, "hogehoge", 32]

: Array

  '['

    | '[' | ���ǿ�(Fixnum����) | ���Ǥ� dump | ... |

  ��:
    p Marshal.dump(["hogehoge", /hogehoge/]).unpack("x2 a c aca8 aca*")
    # => ["[", 7, "\"", 13, "hogehoge", "/", 13, "hogehoge\000"]

: Hash

  '{'

    | '{' | ���ǿ�(Fixnum����) | ������ dump | �ͤ� dump | ... |

  ��:
    p Marshal.dump({"hogehoge", /hogehoge/}).unpack("x2 a c aca8 aca*")
    # => ["{", 6, "\"", 13, "hogehoge", "/", 13, "hogehoge\000"]

: Hash with default value ( not Proc )

  '}'

    | '}' | ���ǿ�(Fixnum����) | ������ dump | �ͤ� dump | ... | �ǥե������ |

  ��:
    h = Hash.new(true)
    h["foo"] = "bar"
    p Marshal.dump(h).unpack("x2 a c aca3 aca*")
    # => ["}", 6, "\"", 8, "foo", "\"", 8, "barT"]

  �ǥե���ȥ��֥������Ȥ� Proc �Ǥ��� Hash �� dump �Ǥ��ʤ�

    h = Hash.new { }
    Marshal.dump(h)
    => -:2:in `dump': cannot dump hash with default proc (TypeError)

: Struct

  'S': ��¤�Υ��饹�Υ��󥹥��󥹤Υ����

    | 'S' | ���饹̾(Symbol) �� dump | ���Фο�(Fixnum����) |
    | ����̾(Symbol) �� dump | �� | ... |

  ��:
    Struct.new("XXX", :foo, :bar)
    p Marshal.dump(Struct::XXX.new).unpack("x2 a ac a11 c aca3a aca3a")
    # => ["S", ":", 16, "Struct::XXX", 7,
          ":", 8, "foo", "0",
          ":", 8, "bar", "0"]

: Class/Module (old format)

  'M'

    | 'M' | Ĺ��(Fixnum����) | �⥸�塼��/���饹̾ |

  ��: ��Ϥ䤳�η����� dump ���뤳�ȤϤǤ��ʤ��Τ� load ����򼨤��Ƥ��롣
    class Mod
    end
    p Marshal.load([4,7, 'M', 3+5, 'Mod'].pack("ccaca*"))
    # => Mod

: Class/Module

  'c', 'm'

    | 'c'/'m' | ���饹̾��Ĺ��(Fixnum ����) | ���饹̾ |

  ��:
    class Foo
    end
    p Marshal.dump(Foo).unpack("x2 a c a*") # => ["c", 8, "Foo"]

  �� 2: ���饹/�⥸�塼��Υ��󥹥����ѿ��� dump ����ʤ�

    module Bar
      @bar = 1
    end
    p Bar.instance_eval { @bar }
    Marshal.dump(Bar, open("/tmp/foo", "w"))
    # => 1

    module Bar
    end
    p bar = Marshal.load(open("/tmp/foo"))
    p bar.instance_eval { @bar }
    # => nil

  �� 3: ���饹�ѿ��� dump ����ʤ�

    module Baz
      @@baz = 1
      def self.baz
        @@baz
      end
    end
    p Baz.baz
    Marshal.dump(Baz, open("/tmp/foo", "w"))
    # => 1

    module Baz
      def self.baz
        @@baz
      end
    end
    p baz = Marshal.load(open("/tmp/foo"))
    baz.baz
    # => Baz
         -:3:in `baz': uninitialized class variable @@baz in Baz (NameError)
                 from -:7

: Symbol

  ':'

    | ':' | ����ܥ�̾��Ĺ��(Fixnum����) | ����ܥ�̾ |

  ��:
    p Marshal.dump(:foo).unpack("x2 a c a*")
    # => [":", 8, "foo"]

: Symbol (link)

  ';'

    | ';' | Symbol�μ��֤�ؤ��ֹ�(Fixnum����) |

  �б����륷��ܥ�̾������ dump/load ����Ƥ�����˻��Ѥ���롣�ֹ�
  �����������Τ�Ρ�(dump/load ���� Symbol �����Ѥ˥ϥå���ơ��֥뤬
  ����롣���Υ쥳���ɰ���)

  ��:
    p Marshal.dump([:foo, :foo]).unpack("x2 ac aca3 aC*")
    # => ["[", 7, ":", 8, "foo", ";", 0]

    p Marshal.dump([:foo, :foo, :bar, :bar]).
        unpack("x2 ac aca3 aC aca3 aC*")
    # => ["[", 9, ":", 8, "foo", ";", 0, ":", 8, "bar", ";", 6]

: instance variable

  'I': Object, Class, Module �Υ��󥹥��󥹰ʳ�

    | 'I' | ���֥������Ȥ� dump | ���󥹥����ѿ��ο�(Fixnum����) |
    | ���󥹥����ѿ�̾(Symbol) ��dump(1) | ��(1) |
              :
              :
    | ���󥹥����ѿ�̾(Symbol) ��dump(n) | ��(n) |

  Object �Υ��󥹥��󥹤Ϥ��켫�Ȥ����󥹥����ѿ��ι�¤����ĤΤ�
  �̷����� dump ����� ([[unknown:Marshal�ե����ޥå�/Object]] ����)
  ���η����ϡ�Array �� String �Υ��󥹥����ѡ�

  ��:
    obj = String.new
    obj.instance_eval { @foo = "bar" }
    p Marshal.dump(obj).unpack("x2 a ac c a c a4 aca*")
    # => ["I", "\"", 0, 6, ":", 9, "@foo", "\"", 8, "bar"]

  ���饹��⥸�塼��(Class/Module �Υ��󥹥���)�ϡ�
  ���󥹥����ѿ��ξ���� dump ���ʤ���
  ([[unknown:Marshal�ե����ޥå�/"Class/Module"]] ����)

: link

  '@'

    | '@' | ���֥������Ȥμ��֤�ؤ��ֹ�(Fixnum���� |

  �б����륪�֥������Ȥ����� dump/load ����Ƥ�����˻��Ѥ���롣��
  ������������Τ�Ρ�(dump/load ���� ���֥������ȴ����Ѥ˥ϥå���ơ�
  �֥뤬����롣���Υ쥳���ɰ���)

  ��:
    obj = Object.new
    p Marshal.dump([obj, obj]).unpack("x2 ac aaca6c aca*")
    # => ["[", 7, "o", ":", 11, "Object", 0, "@", 6, ""]

    ary = []
    ary.push ary
    p Marshal.dump(ary).unpack("x2 acac")

    # => ["[", 6, "@", 0]

== Marshal �ΥХ�

���� ruby version 1.6 �ˤϡ����줾��ΥС������ǰʲ��ΥХ��������
���������()��ε��Ҥ�����ε�ư(1.7 �ο���ޤ�)�Ǥ���

: <= 1.6.7
    * ���饹�� clone ������ΤΥ��󥹥��󥹤ϥ���פǤ��뤬������
      �ɤǤ��ʤ�(̵̾���饹�Υ��֥������Ȥˤʤ�Τǥ���פǤ��ʤ�)
    * ̵̾ Module �� include/extend �ˤ���ðۥ᥽�åɤ�������줿
      ���֥������Ȥ����ס������ɤǤ���(̵̾�⥸�塼��� include
      �������֥������Ȥϥ���פǤ��ʤ�)

: 1.6.6, 1.6.7

    * ���󥹥����ѿ������ Array �� String �ϥ���פǤ��뤬��
      �����ɤǤ��ʤ�(����ס������ɤǤ���)

: <= 1.6.5
    * ���饹�� clone ������ΤΥ��󥹥��󥹤ϥ���פǤ��뤬������
      �ɤ�����Ѥʥ��֥������Ȥ��Ǥ���(?)
    * �ðۥ��饹�ϡ��ðۤǤʤ����饹�˥���פ����(�ðۥ��饹�ϥ���פǤ��ʤ�)
    * ̵̾���饹�ϡ�����פǤ��뤬�����ɤǤ��ʤ�(̵̾���饹�ϥ���פǤ��ʤ�)

: <= 1.6.4
    * �⥸�塼��ϥ���פǤ��뤬�����ɤǤ��ʤ�(�����ɤǤ���)
    * ̵̾�⥸�塼��ϡ�����פǤ��뤬�����ɤǤ��ʤ�(̵̾�⥸�塼
      ��ϥ���פǤ��ʤ�)

: <= 1.6.3
    * Float �����פ����Ȥ�����¸�������٤��㤤

: <= 1.6.2
    * ����ɽ���� /m, /x ���ץ�����̵ͭ������׻�����¸����ʤ�

: 1.6.2, 1.6.3
    * 1.6.2, 1.6.3�Τ�Bignum �����פ�����Τ�����ɤǤ��ʤ�
      ���δ�Ϣ�Х���¾�ˤ⤢�ä��Ȼפ����Ƹ�������ץȤ�������

: <= 1.6.1
    * Range ����ü��ޤफ�ɤ����Υե饰������׻�����¸����ʤ�

�ʲ��ϡ��ƥ��ȥ�����ץȤǤ�(�� [[c:RAA:RubyUnit]])

    # test for Marshal for ruby version 1.6
    require 'rubyunit'

    $version_dependent_behavior = true
    # for test_userClass, test_userModule
    module UserModule
      def foo
      end
    end
    class UserClass
      def foo
      end
    end

    class TestMarshal < RUNIT::TestCase

      def assert_no_dumpable(obj)
        ex = assert_exception(TypeError) {
          begin
            # Marshal.dump will cause TypeError or ArgumentError
            Marshal.dump obj
          rescue ArgumentError
            case $!.message
            when /can't dump anonymous/,
                 /cannot dump hash with default proc/
              raise TypeError
            else
              raise "unknown error"
            end
          end
        }
      end
      def assert_dumpable_but_not_equal(obj)
        obj2 = Marshal.load(Marshal.dump(obj))
        assert(obj != obj2)
        assert_equals(obj.class, obj2.class)
      end
      def assert_dumpable_and_equal(obj)
        obj2 = Marshal.load(Marshal.dump(obj))
        assert_equals(obj, obj2)
        assert_equals(obj.class, obj2.class)

        # check values of instance variable
        ivars = obj.instance_variables
        ivars2 = obj2.instance_variables
        assert_equals(ivars, ivars2)
        while ivars.size != 0
          assert_equals(obj.instance_eval(ivars.shift),
                        obj2.instance_eval(ivars2.shift))
        end
      end

      def test_Object
        assert_dumpable_but_not_equal Object.new
      end

      # object with singleton method
      def test_Object_with_singleton_method
        obj = Object.new
        # On ruby version 1.6.0 - 1.6.2, cause parse error (nested method)
        class <<obj
          def foo
          end
        end

        # object has singleton method can't be dumped
        assert_no_dumpable obj
      end

      # object with singleton method (with named module)
      def test_Object_with_singleton_method2
        obj = Object.new
        # On ruby version 1.6.0 - 1.6.2, cause parse error (nested method)
        class <<obj
          include UserModule
        end

        # On ruby version 1.6.0 - 1.6.7, no consider the singleton
        # method with Mix-in.
        # On ruby version 1.7, dumpable object which is extended by
        # named module.
        assert_dumpable_but_not_equal obj
      end

      # object with singleton method (with anonymous module)
      def test_Object_with_singleton_method3
        obj = Object.new
        # On ruby version 1.6.0 - 1.6.2, cause parse error (nested method)
        class <<obj
          include Module.new
        end

        if $version_dependent_behavior and RUBY_VERSION <= "1.6.7"
          # On ruby version 1.6.0 - 1.6.7, no consider the singleton method with Mix-in.
          assert_dumpable_but_not_equal obj
        else
          # object has singleton method (with anonymous module) can't be dumped
          assert_no_dumpable obj
        end
      end

      # singleton class
      def test_singletonClass
        obj = Object.new
        # On ruby version 1.6.0 - 1.6.2, cause parse error (nested method)
        singleton_class = class <<obj
                            def foo
                            end
                            self
                          end

        # singleton class can't be dumped
        # On ruby version 1.6.0 - 1.6.5, singleton class be able to dumped
        # as normal class.
        if $version_dependent_behavior and RUBY_VERSION <= "1.6.5"
          assert_equals(Object, Marshal.load(Marshal.dump(singleton_class)))
        else
          assert_no_dumpable singleton_class
        end
      end

      def test_Array
        assert_dumpable_and_equal [1,"foo", :foo]
      end

      def test_Array_with_instance_variable
        ary = [1,"foo", :foo]
        ary.instance_eval{ @var = 1 }

        if $version_dependent_behavior and %w(1.6.6 1.6.7).member?(RUBY_VERSION)
          # On ruby version 1.6.6 - 1.6.7, Array(or String ...) has instance
          # variable is able to be dumped, but can't load it.
          dump = Marshal.dump(ary)
          ex = assert_exception(ArgumentError) {
            Marshal.load(dump)
          }
        else
          assert_dumpable_and_equal ary
        end
      end

      def test_Binding
        assert_no_dumpable binding
      end

      def test_Continuation
        assert_no_dumpable callcc {|c| c}
      end

      def test_Data
        # assert_fail("")
      end

      def test_Exception
        assert_dumpable_but_not_equal Exception.new("hoge")
      end

      def test_Dir
        assert_no_dumpable Dir.open("/")
      end

      def test_FalseClass
        assert_dumpable_and_equal false
      end

      def test_File__Stat
        assert_no_dumpable File.stat("/")
      end

      def test_Hash
        assert_dumpable_and_equal(1=>"1",2=>"2")

        # 1.7 feature.
        if $version_dependent_behavior and RUBY_VERSION >= '1.7.0'
          # On ruby version 1.7, hash with default Proc cannot be dumped.
          # see [ruby-dev:15417]
          assert_no_dumpable(Hash.new { })
        end
      end

      def test_IO
        assert_no_dumpable IO.new(0)
      end

      def test_File
        assert_no_dumpable File.open("/")
      end

      def test_MatchData
        assert_no_dumpable(/foo/ =~ "foo" && $~)
      end

      def test_Method
        assert_no_dumpable Object.method(:method)
      end

      def test_UnboundMethod
        assert_no_dumpable Object.instance_method(:id)
      end

      def test_Module
        # On ruby version 1.6.0 - 1.6.4, loaded module is not a module.
        if $version_dependent_behavior and RUBY_VERSION <= '1.6.4'
          dump = Marshal.dump Enumerable
          ex = assert_exception(TypeError) {
            Marshal.load dump
          }
          assert_matches(ex.message, /is not a module/)
        else
          assert_dumpable_and_equal Enumerable
        end
      end

      def test_userModule
        # On ruby version 1.6.0 - 1.6.4, loaded module is not a module.
        if $version_dependent_behavior and RUBY_VERSION <= '1.6.4'
          # same as test_Module
        else
          # Note: this module must be defineed for Marshal.load.
          assert_dumpable_and_equal(UserModule)
        end
      end

      def test_anonymousModule
        # On ruby version 1.6.0 - 1.6.4, anonymous class is able to be dumped,
        # but loaded object is not identical.
        if $version_dependent_behavior and RUBY_VERSION <= '1.6.4'
          dump = Marshal.dump(Module.new)
          ex = assert_exception(ArgumentError) {
            Marshal.load dump
          }
          assert_matches(ex.message, /can\'t retrieve anonymous class/)
        else
          assert_no_dumpable Module.new
        end
      end

      def test_Class
        assert_dumpable_and_equal Class
      end

      def test_userClass
        # Note: this class must be defineed for Marshal.load.
        assert_dumpable_and_equal(UserClass)
      end
      def test_anonymousClass
        # On ruby version 1.6.0 - 1.6.5, anonymous class able to be dumped,
        # but can't load it.
        if $version_dependent_behavior and RUBY_VERSION <= '1.6.5'
          dump = Marshal.dump(Class.new)
          ex = assert_exception(ArgumentError) {
            Marshal.load(dump)
          }
          assert_matches(ex.message, /can\'t retrieve anonymous class/)
        else
          assert_no_dumpable Class.new
        end
      end

      def test_clonedClass
        # On ruby version 1.6.0 - 1.6.7, instance of cloned class is able to
        # dumped, but loaded object is not identical.
        # see [ruby-dev:14961]
        if $version_dependent_behavior
          if RUBY_VERSION <= '1.6.5'
            obj = String.clone.new("foo")
            dump = Marshal.dump(obj)
            obj2 = Marshal.load dump
            assert(obj == obj2)
            assert(obj.class != obj2.class)
            assert(obj.class.inspect == obj2.class.inspect)
          elsif RUBY_VERSION <= '1.6.7'
            dump = Marshal.dump(String.clone.new("foo"))
            assert_exception(ArgumentError) {
              Marshal.load dump
            }
          else
            assert_no_dumpable String.clone.new("foo")
          end
        else
          # anonymous class can't be dumped
          assert_no_dumpable String.clone.new("foo")
        end
      end

      def test_Numeric
        # assert_fail("")
      end

      def test_Integer
        # assert_fail("")
      end

      def test_Fixnum
        assert_dumpable_and_equal 100
      end

      def test_Bignum
        # derived from Rubicon
        assert_dumpable_and_equal 123456789012345678901234567890
        assert_dumpable_and_equal -123**99
        if $version_dependent_behavior and %w(1.6.2 1.6.3).member?(RUBY_VERSION)
          dump = Marshal.dump 2**32
          ex = assert_exception(ArgumentError) {
            Marshal.load(dump)
          }
          assert_matches(ex.message, /marshal data too short/)
        else
          assert_dumpable_and_equal 2**32
        end
      end

      def test_Float
        assert_dumpable_and_equal 1.41421356

        # On ruby version 1.6.4, dumped format changed from "%.12g" to "%.16g"
        if $version_dependent_behavior and RUBY_VERSION <= '1.6.3'
          assert_dumpable_but_not_equal Math::PI
        else
          assert_dumpable_and_equal Math::PI
        end
      end

      def test_Proc
        assert_no_dumpable proc { }
      end

      def test_Process__Status
        assert_dumpable_and_equal system("true") && $?
      end

      def test_Range
        # Range#== is changed from 1.6.2
        # On ruby version 1.6.0 - 1.6.1, Range.new(1,2) != Range.new(1,2)
        # assert_dumpable_and_equal 1..2
        # assert_dumpable_and_equal 1...2

        obj = Marshal.load(Marshal.dump 1..2)
        assert_equals(1, obj.begin)
        assert_equals(2, obj.end)
        assert_equals(false, obj.exclude_end?)

        obj = Marshal.load(Marshal.dump 1...2)
        assert_equals(1, obj.begin)
        assert_equals(2, obj.end)

        # On ruby version 1.6.0 - 1.6.1, the attribute exclude_end? is not saved.
        if $version_dependent_behavior and RUBY_VERSION <= '1.6.1'
          assert_equals(false, obj.exclude_end?)
        else
          assert_equals(true, obj.exclude_end?)
        end
      end

      def test_Regexp
        # this test is no consider the /foo/p
        assert_dumpable_and_equal /foo/
        assert_dumpable_and_equal /foo/i
        assert_dumpable_and_equal /foo/m
        assert_dumpable_and_equal /foo/x
        assert_dumpable_and_equal /foo/e
        assert_dumpable_and_equal /foo/s
        assert_dumpable_and_equal /foo/u

        # On ruby version 1.6.0 - 1.6.2, Regexp#== is ignore the option.
        for obj in [/foo/, /foo/i, /foo/m, /foo/x, /foo/e, /foo/s, /foo/u]
          obj2 = Marshal.load(Marshal.dump obj)

          if $version_dependent_behavior and RUBY_VERSION <= '1.6.2' and
              %w(/foo/m /foo/x).member?(obj.inspect)
            # On ruby version 1.6.0 - 1.6.2,
            # //m options is not saved.
            assert_equals('/foo/', obj2.inspect)
          else
            assert_equals(obj.inspect, obj2.inspect)
          end
        end
      end

      def test_String
        assert_dumpable_and_equal "foo"
      end

      def test_Struct
        assert_dumpable_and_equal Struct.new("Foo", :foo, :bar)

        Object.const_set('Foo', Struct.new(:foo, :bar))
        assert_dumpable_and_equal Foo
      end

      def test_aStruct
        assert_dumpable_and_equal Struct.new("Bar", :foo, :bar).new("foo", "bar")

        # see [ruby-dev:14961]
      end

      def test_Symbol
        assert_dumpable_and_equal :foo
      end

      def test_Thread
        assert_no_dumpable Thread.new { sleep }
      end

      def test_ThreadGroup
        assert_no_dumpable ThreadGroup::Default
      end

      def test_Time
        assert_dumpable_and_equal Time.now
        assert_dumpable_and_equal Time.now.gmtime

        # time zone is not saved.
        assert_equals(false, Marshal.load(Marshal.dump(Time.now)).utc?)
        assert_equals(false, Marshal.load(Marshal.dump(Time.now.gmtime)).utc?)
      end

      def test_TrueClass
        assert_dumpable_and_equal true
      end

      def test_NilClass
        assert_dumpable_and_equal nil
      end
    end