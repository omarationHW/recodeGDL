<template>
  <div class="p-6">
    <!-- Estado de carga -->
    <div v-if="loading" class="text-center py-8">
      <div class="spinner-border" role="status">
        <span class="sr-only">Cargando...</span>
      </div>
      <p class="mt-2 text-muted">Cargando {{ componentName }}...</p>
    </div>
    
    <!-- Estado de error -->
    <div v-else-if="error" class="alert alert-danger" role="alert">
      <h4>Error al cargar componente</h4>
      {{ error }}
    </div>
    
    <!-- Componente cargado -->
    <component v-else-if="currentComponent" :is="currentComponent" :key="componentName" />
    
    <!-- Componente no encontrado -->
    <div v-else class="text-center py-8">
      <h3>Componente no encontrado</h3>
      <p>El componente "{{ componentName }}" no está disponible.</p>
      <p class="text-muted">Ruta: /apremios/{{ componentName }}</p>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch, markRaw } from 'vue'
import { useRoute } from 'vue-router'

export default {
  name: 'ApremiosGeneric',
  setup() {
    const route = useRoute()
    const currentComponent = ref(null)
    const loading = ref(true)
    const error = ref(null)
    
    // Control de logs de depuración (solo en DEV o si VITE_DEBUG_APREMIOS === 'true')
    const isDebug = (
      (import.meta && import.meta.env && import.meta.env.DEV) ||
      (import.meta && import.meta.env && import.meta.env.VITE_DEBUG_APREMIOS === 'true')
    )
    const dlog = (...args) => { if (isDebug) console.log(...args) }
    const dwarn = (...args) => { if (isDebug) console.warn(...args) }
    
    const componentName = computed(() => {
      return route.params.submodule || ''
    })
    
    // Cargar dinámicamente todos los .vue disponibles en el módulo apremios
    const modules = import.meta.glob('../../components/modules/apremios/*.vue')
    const availableFiles = Object.keys(modules).map(p => {
      const fname = p.split('/').pop() || ''
      return fname.replace(/\.vue$/i, '')
    })

    // Función para encontrar el archivo más similar
    const findBestMatch = (searchName) => {
      const search = searchName.toLowerCase()
      
      // Buscar coincidencia exacta (sin distinción de mayúsculas)
      for (const file of availableFiles) {
        if (file.toLowerCase() === search) {
          return file
        }
      }
      
      // Buscar coincidencia sin guiones bajos ni espacios
      const cleanSearch = search.replace(/[_\s-]/g, '')
      for (const file of availableFiles) {
        if (file.toLowerCase().replace(/[_\s-]/g, '') === cleanSearch) {
          return file
        }
      }
      
      // Buscar coincidencias parciales (contiene)
      const matches = availableFiles.filter(file => 
        file.toLowerCase().includes(search) || 
        search.includes(file.toLowerCase()) ||
        file.toLowerCase().replace(/[_\s-]/g, '').includes(cleanSearch)
      )
      
      if (matches.length > 0) {
        // Devolver la coincidencia más exacta (por longitud)
        return matches.sort((a, b) => Math.abs(a.length - search.length) - Math.abs(b.length - search.length))[0]
      }
      
      return null
    }

    const loadComponent = async () => {
      dlog(`🔄 Iniciando carga del componente: ${componentName.value}`)
      
      if (!componentName.value) {
        dlog('❌ No hay componentName, terminando carga')
        loading.value = false
        return
      }
      
      try {
        dlog('⏳ Estableciendo loading = true')
        loading.value = true
        error.value = null
        
        // Buscar el archivo más similar
        const bestMatch = findBestMatch(componentName.value)
        
        if (bestMatch) {
          dlog(`🎯 Archivo encontrado: ${bestMatch}.vue para ruta ${componentName.value}`)
          
          try {
            const importPath = `../../components/modules/apremios/${bestMatch}.vue`
            const importer = modules[importPath]
            if (!importer) {
              throw new Error(`No se encontró importador para ${importPath}`)
            }
            const componentModule = await importer()
            
            if (componentModule.default || componentModule) {
              currentComponent.value = markRaw(componentModule.default || componentModule)
              dlog('✅ Componente cargado correctamente')
            } else {
              throw new Error('El módulo importado no tiene un export default válido')
            }
          } catch (importError) {
            dwarn(`⚠️ El archivo ${bestMatch}.vue existe pero está corrupto, mostrando placeholder`)
            
            // Crear un componente placeholder para archivos corruptos
            const placeholderComponent = {
              render() {
                return {
                  type: 'div',
                  props: { class: 'container-fluid mt-4' },
                  children: [
                    {
                      type: 'div',
                      props: { class: 'alert alert-warning', role: 'alert' },
                      children: [
                        {
                          type: 'h4',
                          props: { class: 'alert-heading' },
                          children: '⚠️ Componente en Desarrollo'
                        },
                        {
                          type: 'p',
                          children: [
                            'El componente ',
                            { type: 'strong', children: bestMatch },
                            ' está actualmente en desarrollo.'
                          ]
                        },
                        { type: 'hr' },
                        {
                          type: 'p',
                          props: { class: 'mb-0' },
                          children: {
                            type: 'small',
                            children: `Módulo: Apremios | Componente: ${componentName.value}`
                          }
                        }
                      ]
                    },
                    {
                      type: 'div',
                      props: { class: 'card' },
                      children: [
                        {
                          type: 'div',
                          props: { class: 'card-header bg-light' },
                          children: {
                            type: 'h5',
                            props: { class: 'mb-0' },
                            children: bestMatch.replace(/([A-Z])/g, ' $1').trim()
                          }
                        },
                        {
                          type: 'div',
                          props: { class: 'card-body' },
                          children: [
                            {
                              type: 'p',
                              props: { class: 'text-muted' },
                              children: 'Este componente será implementado próximamente.'
                            },
                            {
                              type: 'div',
                              props: { class: 'd-flex justify-content-between' },
                              children: [
                                {
                                  type: 'small',
                                  props: { class: 'text-muted' },
                                  children: 'Estado: En desarrollo'
                                },
                                {
                                  type: 'small',
                                  props: { class: 'text-muted' },
                                  children: 'Módulo: Apremios'
                                }
                              ]
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              }
            }
            
            currentComponent.value = markRaw(placeholderComponent)
            dlog('📋 Componente placeholder cargado')
          }
        } else {
          console.error(`❌ No se encontró componente para: ${componentName.value}`)
          console.error('Archivos disponibles:', availableFiles)
          throw new Error(`No se pudo encontrar el componente "${componentName.value}". Archivos disponibles: ${availableFiles.slice(0, 5).join(', ')}...`)
        }
        
      } catch (err) {
        console.error('❌ Error cargando componente de apremios:', err)
        error.value = `Error al cargar el componente: ${err.message}`
        currentComponent.value = null
      } finally {
        dlog('🏁 Estableciendo loading = false')
        loading.value = false
      }
    }
    
    // Cargar componente al montar
    onMounted(() => {
      loadComponent()
    })
    
    // Recargar componente cuando cambie la ruta
    watch(componentName, (newName, oldName) => {
      if (newName && newName !== oldName) {
        dlog(`🔄 Cambiando componente de ${oldName} a ${newName}`)
        // Scroll al inicio cuando cambia el submódulo
        window.scrollTo({ top: 0, behavior: 'smooth' })
        currentComponent.value = null
        loadComponent()
      }
    })
    
    return {
      currentComponent,
      loading,
      error,
      componentName
    }
  }
}
</script>
