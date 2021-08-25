project('react-qjs', 'cpp',
  version : '0.1',
  default_options : ['warning_level=3', 'cpp_std=c++14']
)

pwd = meson.current_source_dir()
cc = meson.get_compiler('cpp')

add_global_arguments('-D_XOPEN_SOURCE_EXTENDED=1', language: 'cpp')
add_global_arguments('-DENABLE_UTF8=1', language: 'cpp')
add_global_arguments('-w', language: 'cpp')

jsoncpp_dep = dependency('jsoncpp', required: true)
onigmo_dep = dependency('onigmo', required: true)
pthread_dep = cc.find_library('pthread', required : true, disabler: true) 

dl_dep = cc.find_library('dl', required : true) 
quickjs_lib = cc.find_library('quickjs', required: false, dirs:['/usr/lib/quickjs', '/usr/local/lib/quickjs'])
if build_machine.system() == 'darwin'
    quickjs_dep = declare_dependency(dependencies: [ dl_dep, quickjs_lib ], include_directories: ['/usr/local/include/quickjs'])
else
    quickjs_dep = declare_dependency(dependencies: [ dl_dep, quickjs_lib ], include_directories: ['/usr/include/quickjs'])
endif

executable('react-qjs',
    'native/main.cpp',
    dependencies: [ quickjs_dep, pthread_dep ],
    install : true
)