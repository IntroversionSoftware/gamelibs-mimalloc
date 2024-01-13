project('mimalloc', 'c', version: '2.1.2', default_options: ['c_std=c11'])

compiler = meson.get_compiler('c')
link_deps = []
cf_exports = []
cf_local = ['-D_GNU_SOURCE']

inc_exports = ['include']
inc_local = ['src']

# Note: instead of doing this, we should follow mimalloc's example and override
# the functions the right way, so we can hook the allocations with Tracy
#if build_machine.system() != 'windows'
#  cf_local += ['-DMI_MALLOC_OVERRIDE']
#endif

sources = [
  'src/alloc.c',
  'src/alloc-aligned.c',
  #'src/alloc-override.c',
  'src/alloc-posix.c',
  'src/arena.c',
  'src/bitmap.c',
  'src/heap.c',
  'src/init.c',
  'src/options.c',
  'src/os.c',
  'src/page.c',
  #'src/page-queue.c',
  'src/random.c',
  'src/segment.c',
  'src/segment-map.c',
  #'src/static.c',
  'src/stats.c',
  'src/prim/prim.c',
]

inc_local = include_directories(inc_exports + inc_local)
inc_exports = include_directories(inc_exports)

lib = static_library(
    'mimalloc',
    sources,
    include_directories: inc_local,
    dependencies: link_deps,
    c_args: cf_local + cf_exports,
)

mimalloc_dep = declare_dependency(
    include_directories: inc_exports,
    compile_args: cf_exports,
    dependencies: link_deps,
    link_with: lib,
    version: meson.project_version()
)

meson.override_dependency('mimalloc', mimalloc_dep)

# vim: set ts=4 sts=4 sw=4 et:
