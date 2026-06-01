<?php $__env->startSection('title', 'Browse Events - Univent'); ?>

<?php $__env->startSection('content'); ?>
    <div class="min-h-screen bg-slate-50/50 pt-28 pb-20 px-4 relative overflow-hidden">
        
        <div class="absolute -top-24 -left-24 w-96 h-96 bg-red-100 rounded-full blur-3xl opacity-80 -z-10"></div>
        <div class="absolute top-1/2 -right-24 w-80 h-80 bg-pink-100 rounded-full blur-3xl opacity-60 -z-10"></div>

        <div class="max-w-7xl mx-auto relative">
            
            <div class="text-center mb-12">
                <h1 class="text-4xl font-extrabold text-slate-900 mb-3 tracking-tight">Browse Events</h1>
                <p class="text-slate-500 font-medium max-w-lg mx-auto">Discover exciting events happening at Telkom
                    University Purwokerto</p>
            </div>

            
            <div class="bg-white p-4 rounded-[2.5rem] border border-slate-100 shadow-xl shadow-slate-200/40 mb-12">
                <form id="filterForm" action="<?php echo e(url()->current()); ?>" method="GET"
                    class="flex flex-col lg:flex-row items-center gap-4 w-full">

                    
                    <div class="relative w-full lg:flex-1 group">
                        <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                            <svg class="w-5 h-5 text-slate-400 group-focus-within:text-red-500 transition-colors"
                                fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                            </svg>
                        </div>
                        <input type="text" name="search" value="<?php echo e(request('search')); ?>"
                            placeholder="Cari judul, lokasi, atau deskripsi..."
                            class="w-full pl-12 pr-4 py-3.5 bg-slate-50 border border-slate-100 rounded-2xl text-sm font-medium focus:ring-0 focus:ring-red-400 focus:border-red-400 transition-all outline-none">
                    </div>

                    
                    <div class="relative w-full lg:w-52 group" x-data="{
                        open: false,
                        search: '',
                        selected: '<?php echo e(request('category') ?: 'All Categories'); ?>',
                        options: ['All Categories', 'Seminar', 'Workshop', 'Competition', 'Gathering', 'Other']
                    }">

                        
                        <input type="hidden" name="category" :value="selected === 'All Categories' ? '' : selected">

                        <button type="button" @click="open = !open"
                            class="w-full flex items-center justify-between px-5 py-3.5 bg-white border border-slate-200 rounded-2xl text-sm font-bold text-slate-700 hover:border-red-300 transition-all">
                            <span x-text="selected"></span>
                            <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open ? 'rotate-180' : ''"
                                fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path d="M19 9l-7 7-7-7" />
                            </svg>
                        </button>

                        <div x-show="open" @click.away="open = false"
                            class="absolute z-30 mt-2 w-full bg-white border border-slate-100 rounded-2xl shadow-xl overflow-hidden flex flex-col"
                            x-cloak>

                            
                            <div class="p-2 border-b border-slate-100">
                                <input type="text" x-model="search" placeholder="Search categories..."
                                    class="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-full text-sm focus:outline-none focus:ring-1 focus:ring-red-400 transition-all"
                                    @click.stop>
                            </div>

                            
                            <div class="max-h-48 overflow-y-auto py-1">
                                <template x-for="cat in options.filter(i => i.toLowerCase().includes(search.toLowerCase()))"
                                    :key="cat">
                                    
                                    <button type="button"
                                        @click="selected = cat; open = false; $nextTick(() => { document.getElementById('filterForm').submit(); })"
                                        class="w-full text-left px-5 py-2.5 text-sm font-medium text-slate-600 hover:bg-red-50 hover:text-red-600 transition-colors">
                                        <span x-text="cat"></span>
                                    </button>
                                </template>

                                
                                <div x-show="options.filter(i => i.toLowerCase().includes(search.toLowerCase())).length === 0"
                                    class="px-5 py-3 text-sm text-slate-400 text-center font-medium">
                                    Tidak ditemukan
                                </div>
                            </div>
                        </div>
                    </div>

                    
                    <div class="relative w-full lg:w-52 group" x-data="{
                        open: false,
                        selected: '<?php echo e(request('organizer') ?: 'All Organizers'); ?>'
                    }">
                        <input type="hidden" name="organizer" :value="selected === 'All Organizers' ? '' : selected">

                        <button type="button" @click="open = !open"
                            class="w-full flex items-center justify-between px-5 py-3.5 bg-white border border-slate-200 rounded-2xl text-sm font-bold text-slate-700 hover:border-red-300 transition-all">
                            <span x-text="selected"></span>
                            <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open ? 'rotate-180' : ''"
                                fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path d="M19 9l-7 7-7-7" />
                            </svg>
                        </button>

                        <div x-show="open" @click.away="open = false"
                            class="absolute z-30 mt-2 w-full bg-white border border-slate-100 rounded-2xl shadow-xl py-2 overflow-hidden"
                            x-cloak>
                            <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::openLoop(); ?><?php endif; ?><?php $__currentLoopData = ['All Organizers', 'Student Association', 'Lecturer', 'External']; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $org): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::startLoopIteration(); ?><?php endif; ?>
                                <button type="button"
                                    @click="selected = '<?php echo e($org); ?>'; open = false; $nextTick(() => { document.getElementById('filterForm').submit(); })"
                                    class="w-full text-left px-5 py-2.5 text-sm font-medium text-slate-600 hover:bg-red-50 hover:text-red-600 transition-colors">
                                    <?php echo e($org); ?>

                                </button>
                            <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::endLoop(); ?><?php endif; ?><?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::closeLoop(); ?><?php endif; ?>
                        </div>
                    </div>

                    
                    <button type="submit" class="hidden"></button>

                    
                    <a href="<?php echo e(url()->current()); ?>"
                        class="w-full lg:w-auto px-6 py-3.5 bg-slate-900 text-white font-bold rounded-2xl hover:bg-red-600 transition-all flex items-center justify-center gap-2">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                        </svg>
                        <span>Reset</span>
                    </a>
                </form>
            </div>

            
            
            
            <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if(isset($recommendedEvents) && $recommendedEvents->isNotEmpty()): ?>
                <div class="mb-16">
                    
                    <div class="flex items-center gap-3 mb-8">
                        <h2 class="text-2xl font-extrabold text-slate-900 tracking-tight">
                            <?php echo e(isset($isPersonalized) && $isPersonalized ? ' Rekomendasi Khusus Untukmu' : '🌟 Sedang Trending di Kampus'); ?>

                        </h2>
                        <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if(isset($isPersonalized) && $isPersonalized): ?>
                            <span class="px-3 py-1 bg-red-100 text-red-600 text-xs font-bold rounded-full">Sesuai
                                Minatmu</span>
                        <?php else: ?>
                            <span class="px-3 py-1 bg-blue-100 text-blue-600 text-xs font-bold rounded-full">Paling Banyak
                                Dicari</span>
                        <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                        <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::openLoop(); ?><?php endif; ?><?php $__currentLoopData = $recommendedEvents; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $event): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::startLoopIteration(); ?><?php endif; ?>
                            <div
                                class="group bg-white rounded-3xl border-2 border-red-100 overflow-hidden shadow-lg shadow-red-100/50 hover:shadow-2xl hover:shadow-red-200/50 transition-all duration-300 transform hover:-translate-y-2">
                                
                                <div class="h-52 relative overflow-hidden bg-slate-200">
                                    <img src=""<?php echo e(strlen($event->event_poster) > 200 ? 'data:image/jpeg;base64,' . $event->event_poster : asset('storage/' . $event->event_poster)); ?>"
                                        class="h-full w-full object-cover group-hover:scale-110 transition duration-500">
                                    <div class="absolute top-4 left-4 flex gap-2">
                                        <span
                                            class="px-3 py-1 bg-red-500 text-white text-[10px] font-extrabold uppercase rounded-lg shadow-sm">
                                            <?php echo e(isset($isPersonalized) && $isPersonalized ? 'Rekomendasi' : 'Trending'); ?>

                                        </span>
                                        <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if($event->tags): ?>
                                            <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::openLoop(); ?><?php endif; ?><?php $__currentLoopData = explode(',', $event->tags); $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $tag): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::startLoopIteration(); ?><?php endif; ?>
                                                <span
                                                    class="px-3 py-1 bg-white/90 backdrop-blur-md text-[10px] font-extrabold uppercase text-slate-700 rounded-lg shadow-sm"><?php echo e($tag); ?></span>
                                            <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::endLoop(); ?><?php endif; ?><?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::closeLoop(); ?><?php endif; ?>
                                        <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>
                                    </div>
                                </div>

                                
                                <div class="p-6">
                                    <h3
                                        class="text-xl font-extrabold text-slate-900 mb-2 group-hover:text-red-500 transition line-clamp-1">
                                        <?php echo e($event->event_title); ?></h3>
                                    <p class="text-sm text-slate-500 line-clamp-2 leading-relaxed mb-6">
                                        <?php echo e($event->event_description); ?></p>

                                    <div class="space-y-3 mb-8">
                                        <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if(!isset($isPersonalized) || !$isPersonalized): ?>
                                            <div class="flex items-center gap-3 text-slate-500">
                                                <div class="p-2 bg-orange-50 rounded-lg text-orange-500">
                                                    <svg class="w-4 h-4" fill="none" stroke="currentColor"
                                                        viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round"
                                                            stroke-width="2"
                                                            d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                                                    </svg>
                                                </div>
                                                <span class="text-xs font-bold"><?php echo e($event->registrations_count ?? 0); ?>

                                                    Pendaftar</span>
                                            </div>
                                        <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>

                                        <div class="flex items-center gap-3 text-slate-500">
                                            <div class="p-2 bg-red-50 rounded-lg text-red-500">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor"
                                                    viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                                </svg>
                                            </div>
                                            <span
                                                class="text-xs font-bold"><?php echo e(date('D, M d, Y', strtotime($event->start_date))); ?></span>
                                        </div>
                                        <div class="flex items-center gap-3 text-slate-500">
                                            <div class="p-2 bg-pink-50 rounded-lg text-pink-500">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor"
                                                    viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                        d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                        d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                                </svg>
                                            </div>
                                            <span
                                                class="text-xs font-bold line-clamp-1"><?php echo e($event->event_location); ?></span>
                                        </div>
                                    </div>

                                    <a href="<?php echo e(route('events.show', $event->id)); ?>"
                                        class="block w-full text-center py-4 bg-red-500 text-white rounded-2xl text-sm font-bold hover:bg-red-600 transition shadow-lg shadow-red-200">
                                        View Details
                                    </a>
                                </div>
                            </div>
                        <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::endLoop(); ?><?php endif; ?><?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::closeLoop(); ?><?php endif; ?>
                    </div>
                </div>

                
                <div class="flex items-center justify-center gap-4 mb-10">
                    <div class="h-px bg-slate-200 w-full max-w-[200px]"></div>
                    <h2 class="text-lg font-bold text-slate-400 uppercase tracking-widest">Semua Event</h2>
                    <div class="h-px bg-slate-200 w-full max-w-[200px]"></div>
                </div>
            <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>

            
            
            
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8" id="events-container">
                <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::openLoop(); ?><?php endif; ?><?php $__empty_1 = true; $__currentLoopData = $events; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $event): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::startLoopIteration(); ?><?php endif; ?>
                    <div
                        class="group bg-white rounded-3xl border border-slate-100 overflow-hidden shadow-sm hover:shadow-2xl hover:shadow-slate-200/50 transition-all duration-300 transform hover:-translate-y-2">
                        
                        <div class="h-52 relative overflow-hidden bg-slate-200">
                            <img src="<?php echo e(strlen($event->event_poster) > 200 ? 'data:image/jpeg;base64,' . $event->event_poster : asset('storage/' . $event->event_poster)); ?>"
                                class="h-full w-full object-cover group-hover:scale-110 transition duration-500">
                            <div class="absolute top-4 left-4 flex gap-2">
                                <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if($event->tags): ?>
                                    <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::openLoop(); ?><?php endif; ?><?php $__currentLoopData = explode(',', $event->tags); $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $tag): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::startLoopIteration(); ?><?php endif; ?>
                                        <span
                                            class="px-3 py-1 bg-white/90 backdrop-blur-md text-[10px] font-extrabold uppercase text-red-600 rounded-lg shadow-sm"><?php echo e($tag); ?></span>
                                    <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::endLoop(); ?><?php endif; ?><?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::closeLoop(); ?><?php endif; ?>
                                <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>
                            </div>
                        </div>

                        
                        <div class="p-6">
                            <h3
                                class="text-xl font-extrabold text-slate-900 mb-2 group-hover:text-red-500 transition line-clamp-1">
                                <?php echo e($event->event_title); ?></h3>
                            <p class="text-sm text-slate-500 line-clamp-2 leading-relaxed mb-6">
                                <?php echo e($event->event_description); ?></p>

                            <div class="space-y-3 mb-8">
                                <div class="flex items-center gap-3 text-slate-500">
                                    <div class="p-2 bg-red-50 rounded-lg text-red-500">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                        </svg>
                                    </div>
                                    <span
                                        class="text-xs font-bold"><?php echo e(date('D, M d, Y', strtotime($event->start_date))); ?></span>
                                </div>
                                <div class="flex items-center gap-3 text-slate-500">
                                    <div class="p-2 bg-pink-50 rounded-lg text-pink-500">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                        </svg>
                                    </div>
                                    <span class="text-xs font-bold line-clamp-1"><?php echo e($event->event_location); ?></span>
                                </div>
                            </div>

                            <a href="<?php echo e(route('events.show', $event->id)); ?>"
                                class="block w-full text-center py-4 bg-slate-900 text-white rounded-2xl text-sm font-bold hover:bg-red-500 transition shadow-lg shadow-slate-200">
                                View Details
                            </a>
                        </div>
                    </div>
                <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::endLoop(); ?><?php endif; ?><?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::closeLoop(); ?><?php endif; ?>
                    <div class="col-span-full py-20 flex flex-col items-center justify-center text-center">
                        <div class="relative mb-6">
                            <div class="absolute inset-0 bg-red-100 rounded-full scale-150 blur-3xl opacity-40"></div>
                            <div
                                class="relative w-20 h-20 bg-gradient-to-br from-red-500 to-pink-500 rounded-2xl flex items-center justify-center shadow-xl shadow-pink-500/20">
                                <svg class="w-10 h-10 text-white" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M9.172 9.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                            </div>
                        </div>
                        <h3 class="text-xl font-bold text-slate-900 mb-2">Pencarian Tidak Ditemukan</h3>
                        <p class="text-sm text-slate-500 max-w-xs mx-auto">Kami tidak dapat menemukan event dengan kriteria
                            pencarian Anda. Coba gunakan kata kunci lain.</p>
                    </div>
                <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>
            </div>
        </div>
    </div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH R:\ABp tubes\univent2.0\ABP\univent 2.0\resources\views/browse-events.blade.php ENDPATH**/ ?>