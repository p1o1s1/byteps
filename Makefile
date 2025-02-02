TF_COMPILE_FLAGS := $(shell python -c "import tensorflow as tf; print(' '.join(tf.sysconfig.get_compile_flags()))")

TF_LINK_FLAGS:= $(shell python -c "import tensorflow as tf; print(' '.join(tf.sysconfig.get_link_flags()))")

all:
		c++ -O3 -rdynamic -std=c++11 -I/usr/local/lib/python3.7/dist-packages/tensorflow/include $(TF_COMPILE_FLAGS) -fPIC -Wall -c plugin.cc -o plugin.o
		c++ -shared -fPIC -Wl,--no-as-needed,-soname,libplugin.so.1 $(TF_LINK_FLAGS) -o libplugin.so plugin.o
		@rm plugin.o

clean:
		@rm libplugin.so

.PHONY: all clean