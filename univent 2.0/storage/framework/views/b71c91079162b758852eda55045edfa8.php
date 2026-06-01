<?php $__env->startSection('title', (isset($event) ? 'Edit Event' : 'Submit Event') . ' - Univent'); ?>

<?php $__env->startSection('content'); ?>
    <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if(auth()->guard()->check()): ?>
        <?php
            $isEditMode = isset($event);
            $formAction = $isEditMode ? route('submit-event.update', $event->id) : route('submit-event');
        ?>

        <div class="absolute -top-24 -left-24 w-96 h-96 bg-red-100 rounded-full blur-3xl opacity-80 -z-10"></div>
        <div class="absolute top-1/2 -right-24 w-80 h-80 bg-pink-100 rounded-full blur-3xl opacity-60 -z-10"></div>

        <div class="min-h-screen pt-28 pb-20 px-4 bg-slate-50/50">
            <div
                class="max-w-3xl mx-auto bg-white rounded-[2.5rem] border border-slate-100 shadow-xl shadow-slate-200/50 overflow-hidden p-8 md:p-12">

                
                <div class="mb-10 text-center md:text-left">
                    <h1 class="text-3xl font-extrabold text-slate-900 mb-2"><?php echo e($isEditMode ? 'Edit Event' : 'Submit Event'); ?>

                    </h1>
                    <p class="text-slate-500 font-medium">Share your event with the Telkom University Purwokerto community. All
                        fields marked with <span class="text-red-500">*</span> are required.</p>
                </div>

                <form action="<?php echo e($formAction); ?>" method="POST" enctype="multipart/form-data" class="space-y-8">
                    <?php echo csrf_field(); ?>
                    <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if($isEditMode): ?>
                        <?php echo method_field('PUT'); ?>
                    <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>

                    
                    <div class="space-y-6">
                        <div class="space-y-2">
                            <label for="event_title" class="text-sm font-bold text-slate-700">Event Title <span
                                    class="text-red-500">*</span></label>
                            <input type="text" id="event_title" name="event_title" required
                                value="<?php echo e(old('event_title', $event->event_title ?? '')); ?>"
                                class="w-full px-5 py-3.5 bg-slate-50 border border-slate-200 rounded-2xl text-sm focus:ring-0 focus:ring-red-400 focus:border-red-400 outline-none transition-all"
                                placeholder="Enter Event Title">
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

                            
                            <div class="space-y-2" x-data="{ open: false, selected: '<?php echo e(old('organizer_type', $event->organizer_type ?? '')); ?>' }">
                                <label class="text-sm font-bold text-slate-700">Organizer Type <span
                                        class="text-red-500">*</span></label>
                                <div class="relative">
                                    <button type="button" @click="open = !open" @click.away="open = false"
                                        class="w-full flex items-center justify-between px-5 py-3.5 bg-slate-50 border border-slate-200 rounded-2xl text-sm text-slate-700 focus:ring-0 focus:ring-red-400 focus:border-red-400 transition-all outline-none">
                                        <span
                                            x-text="selected === 'Student Association' ? 'Student Association' : (selected === 'Lecturer' ? 'Lecturer' : (selected === 'External' ? 'External' : 'Select type'))"
                                            :class="selected === '' ? 'text-slate-400' : 'text-slate-700'"></span>

                                        
                                        <?php if (isset($component)) { $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c = $attributes; } ?>
<?php $component = BladeUI\Icons\Components\Svg::resolve([] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('heroicon-o-chevron-down'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\BladeUI\Icons\Components\Svg::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes(['class' => 'w-4 h-4 text-slate-400 transition-transform duration-200','x-bind:class' => 'open ? \'rotate-180\' : \'\'']); ?>
<?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::processComponentKey($component); ?>

<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $attributes = $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $component = $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
                                    </button>
                                    <input type="hidden" name="organizer_type" x-model="selected" required>

                                    <div x-show="open" x-transition.opacity x-transition:enter.duration.200ms
                                        x-transition:leave.duration.100ms
                                        class="absolute z-30 mt-2 w-full bg-white border border-slate-100 rounded-2xl shadow-xl py-2 overflow-hidden"
                                        style="display: none;">
                                        <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::openLoop(); ?><?php endif; ?><?php $__currentLoopData = ['Student Association', 'Lecturer', 'External']; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $label): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::startLoopIteration(); ?><?php endif; ?>
                                            <button type="button" @click="selected = '<?php echo e($label); ?>'; open = false"
                                                class="w-full text-left px-5 py-2.5 text-sm text-slate-600 hover:bg-red-50 hover:text-red-600 transition-colors"><?php echo e($label); ?></button>
                                        <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::endLoop(); ?><?php endif; ?><?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::closeLoop(); ?><?php endif; ?>
                                    </div>
                                </div>
                            </div>

                            
                            <div class="space-y-2" x-data="{
                                open: false,
                                search: '',
                                selectedId: '<?php echo e(old('category_id', $event->category_id ?? '')); ?>',
                                selectedName: 'Select Category',
                                newCategoryName: '<?php echo e(old('new_category_name', '')); ?>',
                                defaultCategories: ['seminar', 'workshop', 'competition', 'gathering', 'other', 'all categories'],
                                categories: [
                                    <?php $__currentLoopData = $categories; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $cat): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                                    { id: '<?php echo e($cat->id); ?>', name: '<?php echo e(addslashes($cat->name)); ?>' }, <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?> { id: 'other', name: 'Other' }
                                ],
                                get filteredCategories() {
                                    let term = this.search.toLowerCase().trim();
                                    if (term === '') {
                                        return this.categories.filter(c => this.defaultCategories.includes(c.name.toLowerCase()));
                                    }
                                    return this.categories.filter(c => c.name.toLowerCase().includes(term));
                                },
                                selectCategory(id, name) {
                                    this.selectedId = id;
                                    this.selectedName = name;
                                    this.newCategoryName = '';
                                    this.open = false;
                                    this.search = '';
                                },
                                addNewCategory() {
                                    this.selectedId = 'other';
                                    this.selectedName = this.search;
                                    this.newCategoryName = this.search;
                                    this.open = false;
                                    this.search = '';
                                }
                            }" x-init="if (selectedId === 'other') {
                                selectedName = newCategoryName ? newCategoryName : 'Other';
                            } else if (selectedId) {
                                let found = categories.find(c => c.id == selectedId);
                                if (found) selectedName = found.name;
                            }">
                                <label class="text-sm font-bold text-slate-700">Event Category <span
                                        class="text-red-500">*</span></label>
                                <div class="relative">

                                    
                                    <button type="button"
                                        @click="open = !open; if(open) $nextTick(() => $refs.searchInput.focus())"
                                        @click.away="open = false"
                                        class="w-full flex items-center justify-between px-5 py-3.5 bg-slate-50 border border-slate-200 rounded-2xl text-sm focus:ring-0 focus:ring-red-400 focus:border-red-400 transition-all outline-none capitalize">
                                        <span x-text="selectedName" id="category_display_name"
                                            :class="selectedId === '' ? 'text-slate-400 lowercase' : 'text-slate-700'"></span>

                                        
                                        <?php if (isset($component)) { $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c = $attributes; } ?>
<?php $component = BladeUI\Icons\Components\Svg::resolve([] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('heroicon-o-chevron-down'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\BladeUI\Icons\Components\Svg::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes(['class' => 'w-4 h-4 text-slate-400 transition-transform duration-200','x-bind:class' => 'open ? \'rotate-180\' : \'\'']); ?>
<?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::processComponentKey($component); ?>

<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $attributes = $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $component = $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
                                    </button>

                                    <input type="hidden" name="category_id" x-model="selectedId" id="category_id_input"
                                        required>
                                    <input type="hidden" name="new_category_name" x-model="newCategoryName"
                                        id="new_category_name_input">

                                    
                                    <div x-show="open" x-transition.opacity x-transition:enter.duration.200ms
                                        x-transition:leave.duration.100ms
                                        class="absolute z-30 mt-2 w-full bg-white border border-slate-100 rounded-2xl shadow-xl py-3"
                                        style="display: none;">

                                        
                                        <div class="px-3 mb-2">
                                            <div class="relative w-full">
                                                
                                                <?php if (isset($component)) { $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c = $attributes; } ?>
<?php $component = BladeUI\Icons\Components\Svg::resolve([] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('heroicon-o-magnifying-glass'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\BladeUI\Icons\Components\Svg::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes(['class' => 'absolute left-3.5 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400']); ?>
<?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::processComponentKey($component); ?>

<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $attributes = $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $component = $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>

                                                
                                                <input type="text" x-ref="searchInput" x-model="search"
                                                    placeholder="Search categories..."
                                                    class="w-full rounded-full border border-slate-200 bg-slate-50 py-2.5 pl-11 pr-12 text-sm text-slate-700 outline-none focus:border-red-400 focus:ring-0 focus:ring-red-400/20 transition-all placeholder:text-slate-400">

                                                
                                                <button type="button"
                                                    x-show="search.trim() !== '' && filteredCategories.length === 0"
                                                    @click="addNewCategory()"
                                                    class="absolute right-3 top-1/2 -translate-y-1/2 flex h-[18px] w-[18px] items-center justify-center rounded-md bg-gradient-to-br from-rose-500 to-rose-600 text-white shadow-sm transition-transform hover:scale-105"
                                                    style="display: none;">
                                                    <?php if (isset($component)) { $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c = $attributes; } ?>
<?php $component = BladeUI\Icons\Components\Svg::resolve([] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('heroicon-o-plus'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\BladeUI\Icons\Components\Svg::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes(['class' => 'w-5 h-5']); ?>
<?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::processComponentKey($component); ?>

<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $attributes = $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $component = $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
                                                </button>
                                            </div>
                                        </div>

                                        
                                        <div class="max-h-52 overflow-y-auto px-2 space-y-0.5">
                                            <template x-for="cat in filteredCategories" :key="cat.id">
                                                <button type="button" @click="selectCategory(cat.id, cat.name)"
                                                    class="w-full text-left px-3 py-2.5 text-sm text-slate-600 hover:bg-red-50 hover:text-red-600 transition-colors capitalize rounded-xl">
                                                    <span x-text="cat.name"></span>
                                                </button>
                                            </template>

                                            
                                            <div x-show="search.trim() !== '' && filteredCategories.length === 0"
                                                class="px-3 py-4 text-center text-sm text-slate-400 font-medium">
                                                Category not found
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>

                    
                    <div class="p-6 bg-slate-50/50 rounded-[2rem] space-y-6 border border-slate-100">
                        <h3 class="text-sm font-black uppercase tracking-widest text-slate-400 mb-4">Event Schedule</h3>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="space-y-2">
                                <label for="start_date" class="text-xs font-bold text-slate-500">Start Date <span
                                        class="text-red-500">*</span></label>
                                <input type="date" id="start_date" name="start_date" required
                                    value="<?php echo e(old('start_date', $event->start_date ?? '')); ?>"
                                    class="w-full px-4 py-3 bg-white border border-slate-200 rounded-xl text-sm focus:ring-1 focus:ring-red-400 outline-none">
                            </div>
                            <div class="space-y-2">
                                <label for="start_time" class="text-xs font-bold text-slate-500">Start Time <span
                                        class="text-red-500">*</span></label>
                                <input type="time" id="start_time" name="start_time" required
                                    value="<?php echo e(old('start_time', $event->start_time ?? '')); ?>"
                                    class="w-full px-4 py-3 bg-white border border-slate-200 rounded-xl text-sm focus:ring-1 focus:ring-red-400 outline-none">
                            </div>
                            <div class="space-y-2">
                                <label for="end_date" class="text-xs font-bold text-slate-500">End Date <span
                                        class="text-red-500">*</span></label>
                                <input type="date" id="end_date" name="end_date" required
                                    value="<?php echo e(old('end_date', $event->end_date ?? '')); ?>"
                                    class="w-full px-4 py-3 bg-white border border-slate-200 rounded-xl text-sm focus:ring-1 focus:ring-red-400 outline-none">
                            </div>
                            <div class="space-y-2">
                                <label for="end_time" class="text-xs font-bold text-slate-500">End Time <span
                                        class="text-red-500">*</span></label>
                                <input type="time" id="end_time" name="end_time" required
                                    value="<?php echo e(old('end_time', $event->end_time ?? '')); ?>"
                                    class="w-full px-4 py-3 bg-white border border-slate-200 rounded-xl text-sm focus:ring-1 focus:ring-red-400 outline-none">
                            </div>
                        </div>
                    </div>

                    
                    <div class="space-y-6">
                        <div class="space-y-2">
                            <div class="flex flex-col md:flex-row md:items-center justify-between mb-2 gap-2">
                                <label for="event_description" class="text-sm font-bold text-slate-700">Description <span
                                        class="text-red-500">*</span></label>

                                <!-- Tombol AI Gemini -->
                                <button type="button" id="btn-generate-ai"
                                    class="text-xs bg-gradient-to-r from-red-600 to-pink-500 hover:from-purple-700 hover:to-indigo-600 text-white font-bold py-2 px-4 rounded-xl flex items-center justify-center transition shadow-md hover:scale-105 active:scale-95 w-full md:w-auto">
                                    ✨ Generate with AI
                                </button>
                            </div>
                            <textarea id="event_description" name="event_description" rows="5" required
                                class="w-full px-5 py-3.5 bg-slate-50 border border-slate-200 rounded-2xl text-sm focus:ring-1 focus:ring-red-400 outline-none resize-none"
                                placeholder="Describe your event..."><?php echo e(old('event_description', $event->event_description ?? '')); ?></textarea>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="space-y-2">
                                <label for="event_location" class="text-sm font-bold text-slate-700">Location <span
                                        class="text-red-500">*</span></label>
                                <input type="text" id="event_location" name="event_location" required
                                    value="<?php echo e(old('event_location', $event->event_location ?? '')); ?>"
                                    class="w-full px-5 py-3.5 bg-slate-50 border border-slate-200 rounded-2xl text-sm focus:ring-1 focus:ring-red-400 outline-none"
                                    placeholder="Enter Location">
                            </div>
                            <div class="space-y-2">
                                <label for="contact_person" class="text-sm font-bold text-slate-700">Contact Person <span
                                        class="text-red-500">*</span></label>
                                <input type="text" id="contact_person" name="contact_person" required
                                    value="<?php echo e(old('contact_person', $event->contact_person ?? '')); ?>"
                                    class="w-full px-5 py-3.5 bg-slate-50 border border-slate-200 rounded-2xl text-sm focus:ring-1 focus:ring-red-400 outline-none"
                                    placeholder="Name (WhatsApp)">
                            </div>
                        </div>

                        <div class="space-y-2">
                            <label for="registration_link" class="text-sm font-bold text-slate-700">Registration Link</label>
                            <input type="url" id="registration_link" name="registration_link"
                                value="<?php echo e(old('registration_link', $event->registration_link ?? '')); ?>"
                                class="w-full px-5 py-3.5 bg-slate-50 border border-slate-200 rounded-2xl text-sm focus:ring-1 focus:ring-red-400 outline-none"
                                placeholder="https://...">
                        </div>
                    </div>

                    
                    <div class="space-y-2">
                        <label class="text-sm font-bold text-slate-700">Event Poster <span
                                class="text-red-500">*</span></label>
                        <div class="relative group" x-data="{ imagePreview: '<?php echo e(isset($event->event_poster) ? (strlen($event->event_poster) > 200 ? 'data:image/jpeg;base64,' . $event->event_poster : asset('storage/' . $event->event_poster)) : ''); ?>' }">
                            <input type="file" name="event_poster" id="event_poster" <?php echo e($isEditMode ? '' : 'required'); ?>

                                class="absolute inset-0 w-full h-full opacity-0 z-20 cursor-pointer" accept="image/*"
                                @change="const file = $event.target.files[0]; if (file) { const reader = new FileReader(); reader.onload = (e) => { imagePreview = e.target.result }; reader.readAsDataURL(file); }">

                            <div
                                class="border-2 border-dashed border-slate-200 rounded-[2rem] p-10 flex flex-col items-center justify-center bg-slate-50 group-hover:bg-red-50 transition-all relative z-10">
                                <template x-if="!imagePreview">
                                    <div class="flex flex-col items-center">
                                        <div
                                            class="w-16 h-16 bg-white rounded-2xl shadow-sm flex items-center justify-center mb-4 text-red-500">
                                            <?php if (isset($component)) { $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c = $attributes; } ?>
<?php $component = BladeUI\Icons\Components\Svg::resolve([] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('heroicon-o-arrow-up-tray'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\BladeUI\Icons\Components\Svg::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes(['class' => 'w-8 h-8']); ?>
<?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::processComponentKey($component); ?>

<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $attributes = $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $component = $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
                                        </div>
                                        <p class="text-sm font-bold text-slate-700">Drag & drop your file here</p>
                                        <p class="text-xs text-slate-400 mt-1">PNG, JPG up to 4MB</p>
                                    </div>
                                </template>
                                <template x-if="imagePreview">
                                    <div class="relative w-full flex flex-col items-center">
                                        <div
                                            class="p-2 bg-white rounded-2xl shadow-md border border-slate-100 max-w-xs overflow-hidden">
                                            <img :src="imagePreview"
                                                class="w-full h-48 object-cover rounded-xl shadow-inner">
                                        </div>
                                        <p class="mt-4 text-xs font-bold text-red-500 bg-red-50 px-3 py-1 rounded-full">Click
                                            or drag to change image</p>
                                    </div>
                                </template>
                            </div>
                        </div>
                    </div>

                    
                    <div class="flex flex-col md:flex-row items-center justify-end gap-4 pt-6 border-t border-slate-100">
                        <button type="reset"
                            class="w-full md:w-auto px-8 py-4 text-sm font-bold text-slate-500 hover:text-red-500 transition-colors">Clear
                            Form</button>
                        <button type="submit"
                            class="w-full md:w-auto px-10 py-4 bg-gradient-to-r from-red-600 to-pink-500 text-white font-bold rounded-2xl shadow-lg shadow-pink-500/25 hover:scale-105 active:scale-95 transition transform">
                            <?php echo e($isEditMode ? 'Update Event' : 'Submit Event'); ?>

                        </button>
                    </div>
                </form>
            </div>
        </div>
    <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>
<?php $__env->stopSection(); ?>

<?php $__env->startPush('scripts'); ?>
    <!-- Hanya jQuery yang tersisa untuk fungsi API Gemini, Select2 sudah 100% dihapus -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <script>
        $(document).ready(function() {
            // AJAX: AI GENERATOR GEMINI
            $('#btn-generate-ai').on('click', async function() {
                let title = $('#event_title').val();
                let catId = $('#category_id_input').val();
                let categoryName = '';

                if (catId === 'other') {
                    categoryName = $('#new_category_name_input').val();
                } else {
                    categoryName = $('#category_display_name').text().trim();
                }

                if (!title || !catId) {
                    alert(
                        "Mohon isi 'Event Title' dan pilih 'Event Category' terlebih dahulu agar AI bisa bekerja maksimal!");
                    return;
                }

                let btn = $(this);
                let originalText = btn.html();
                btn.html('⏳ Sedang Menulis...');
                btn.prop('disabled', true).addClass('opacity-50 cursor-not-allowed');

                try {
                    let response = await fetch("<?php echo e(route('event.generate-description')); ?>", {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': '<?php echo e(csrf_token()); ?>'
                        },
                        body: JSON.stringify({
                            title: title,
                            category_name: categoryName
                        })
                    });

                    let data = await response.json();

                    if (data.success) {
                        $('#event_description').val(data.description);
                    } else {
                        alert("Gagal: " + data.message);
                    }
                } catch (error) {
                    alert("Terjadi kesalahan sistem saat menghubungi AI.");
                    console.error(error);
                } finally {
                    btn.html(originalText);
                    btn.prop('disabled', false).removeClass('opacity-50 cursor-not-allowed');
                }
            });
        });
    </script>
<?php $__env->stopPush(); ?>

<?php echo $__env->make('layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH R:\ABp tubes\univent2.0\ABP\univent 2.0\resources\views/submit-event.blade.php ENDPATH**/ ?>