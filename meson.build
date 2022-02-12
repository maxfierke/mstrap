project('mstrap',
  'c',
  meson_version : '>= 0.60.0',
  license : 'MIT',
  version : '0.4.0',
  default_options : [
    'default_library=static'
  ]
)

cc = meson.get_compiler('c')
crystal = find_program('crystal', required : true)
shards = find_program('shards', required : true)

libcrypto = dependency('libcrypto', version : '>= 1.1.1')
libevent = dependency('libevent', version : '>= 2.1.2')
libgc = dependency('bdw-gc', version : '>= 8.0.4' )
libiconv = dependency('iconv')
libm = cc.find_library('m', required : false)
libpcre = dependency('libpcre', version : '>= 8.37')
libssl = dependency('libssl', version : '>= 1.1.1')
readline = dependency('readline', 'libedit')
zlib = dependency('zlib')
thread_dep = dependency('threads')

target_arch = host_machine.cpu_family()
target_system = host_machine.system()
target_triple = target_arch + '-unknown-' + target_system

if target_system == 'linux'
  # TODO: musl
  target_triple += '-gnu'
endif

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

mstrap_o = custom_target(
  'mstrap.o',
  build_always_stale : true,
  command : [
    crystal,
    'build',
    '--cross-compile',
    '--target',
    target_triple,
    '-o',
    'mstrap',
    '@INPUT@'
  ],
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
