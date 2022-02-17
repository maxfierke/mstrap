project('mstrap',
  'c',
  meson_version : '>= 0.60.0',
  license : 'MIT',
  version : '0.4.0',
  default_options : [
    'buildtype=debugoptimized',
    'default_library=static'
  ]
)

target_arch = host_machine.cpu_family()
target_system = host_machine.system()
target_triple = target_arch + '-unknown-' + target_system

if target_system == 'linux'
  # TODO: musl
  target_triple += '-gnu'
endif


buildtype = get_option('buildtype')
is_darwin = target_system == 'darwin'
is_static = get_option('default_library') == 'static'

cc = meson.get_compiler('c')
crystal = find_program('crystal', required : true)
shards = find_program('shards', required : true)
libcrypto = dependency('libcrypto', version : '>= 1.1.1', static : is_static)
libevent = dependency('libevent', version : '>= 2.1.2', static : is_static)
libgc = dependency('bdw-gc', version : '>= 8.0.4', static : is_static)
libiconv = dependency('iconv', static : is_static and not is_darwin)
libm = cc.find_library('m', required : false, static : is_static)
libpcre = dependency('libpcre', version : '>= 8.37', static : is_static)
libssl = dependency('libssl', version : '>= 1.1.1', static : is_static)
readline = dependency('readline', 'libedit', static : is_static and not is_darwin)
zlib = dependency('zlib', static : is_static and not is_darwin)
thread_dep = dependency('threads', static : is_static)

if run_command(shards, 'check', check : false).returncode() != 0
  run_command(shards, 'install', '--frozen', check : true)
endif

crystal_path = run_command(
  crystal, 'env', 'CRYSTAL_PATH',
  check : true
).stdout().strip()
env = environment({
  'CRYSTAL_PATH': crystal_path
})
env.prepend('CRYSTAL_PATH', join_paths(meson.project_source_root(), 'lib'))

crystal_build_flags = [
  '--cross-compile',
  '--target',
  target_triple,
]

if buildtype.contains('debug')
  crystal_build_flags += ['--debug']
else
  crystal_build_flags += ['--no-debug']
endif

if buildtype in ['release', 'debugoptimized']
  crystal_build_flags += ['--release']
endif

mstrap_build_cmd = [crystal, 'build'] + crystal_build_flags + ['-o', 'mstrap', '@INPUT@']

mstrap_o = custom_target(
  'mstrap.o',
  build_always_stale : true,
  command : mstrap_build_cmd,
  depend_files : [files('shard.lock')],
  env : env,
  input : [files('src/cli.cr')],
  output : ['mstrap.o']
)

executable(
  'mstrap',
  mstrap_o,
  dependencies : [
    libcrypto,
    libevent,
    libgc,
    libiconv,
    libm,
    libpcre,
    libssl,
    readline,
    zlib,
    thread_dep
  ],
)
