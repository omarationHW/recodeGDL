<template>
  <div class="p-6">
    <div v-if="loading" class="text-center py-8">
      <div class="spinner-border" role="status">
        <span class="sr-only">Cargando...</span>
      </div>
    </div>
    
    <div v-else-if="error" class="alert alert-danger" role="alert">
      {{ error }}
    </div>
    
    <component v-else-if="currentComponent" :is="currentComponent" :key="componentName" />
    
    <div v-else class="text-center py-8">
      <h3>Componente no encontrado</h3>
      <p>El componente "{{ componentName }}" no está disponible.</p>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch, markRaw } from 'vue'
import { useRoute } from 'vue-router'

export default {
  name: 'MercadosGeneric',
  setup() {
    const route = useRoute()
    const currentComponent = ref(null)
    const loading = ref(true)
    const error = ref(null)
    
    const componentName = computed(() => {
      return route.params.submodule || ''
    })
    
    // Lista de archivos reales disponibles en el módulo mercados
    const availableFiles = [
      "Acceso", "AdeEnergiaGrl", "AdeGlobalLocales", "AdeudosEnergia", "AdeudosLocales", "AdeudosLocGrl", "AltaPagos", "AltaPagosEnergia", "AutCargaPagos", "AutCargaPagosMtto", "CargaDiversosEsp", "CargaPagEnergia", "CargaPagEnergiaElec", "CargaPagEspecial", "CargaPagLocales", "CargaPagMercado", "CargaPagosTexto", "CargaReqPagados", "CargaTCultural", "CatalogoMercados", "CatalogoMntto", "Categoria", "CategoriaMntto", "Condonacion", "ConsCapturaEnergia", "ConsCapturaFecha", "ConsCapturaFechaEnergia", "ConsCapturaMerc", "ConsCondonacion", "ConsCondonacionEnergia", "ConsPagos", "ConsPagosEnergia", "ConsPagosLocales", "ConsRequerimientos", "ConsultaDatosEnergia", "ConsultaDatosLocales", "ConsultaGeneral", "CuentaPublica", "CuotasEnergia", "CuotasEnergiaMntto", "CuotasMdo", "CuotasMdoMntto", "CveCuota", "CveCuotaMntto", "CveDiferencias", "CveDiferMntto", "DatosConvenio", "DatosIndividuales", "DatosMovimientos", "DatosRequerimientos", "EmisionEnergia", "EmisionLibertad", "EmisionLocales", "EnergiaModif", "EnergiaMtto", "Estadisticas", "EstadPagosyAdeudos", "FechaDescuento", "FechasDescuentoMntto", "IngresoCaptura", "IngresoLib", "ListadosLocales", "LocalesModif", "LocalesMtto", "Menu", "ModuloBD", "PadronEnergia", "PadronGlobal", "PadronLocales", "PagosDifIngresos", "PagosEneCons", "PagosIndividual", "PagosLocGrl", "PasoAdeudos", "PasoEne", "PasoMdos", "Prescripcion", "Recargos", "RecargosMntto", "RprtSalvadas", "RptAdeEnergiaGrl", "RptAdeudosAbastos1998", "RptAdeudosAnteriores", "RptAdeudosEnergia", "RptAdeudosLocales", "RptCaratulaDatos", "RptCaratulaEnergia", "RptCatalogoMerc", "RptCuentaPublica", "RptDesgloceAdeporImporte", "RptEmisionEnergia", "RptEmisionLaser", "RptEmisionLocales", "RptEmisionRbosAbastos", "RptEstadisticaAdeudos", "RptEstadPagosyAdeudos", "RptFacturaEmision", "RptFacturaEnergia", "RptIngresoZonificado", "RptMovimientos", "RptPadronEnergia", "RptPadronGlobal", "RptPadronLocales", "RptPagosLocales", "Secciones", "SeccionesMntto", "TrDocumentos"
    ]

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
        return matches.sort((a, b) => Math.abs(a.length - search.length) - Math.abs(b.length - search.length))[0]
      }
      
      return null
    }

    const loadComponent = async () => {
      if (!componentName.value) {
        loading.value = false
        return
      }
      
      try {
        loading.value = true
        error.value = null
        
        const bestMatch = findBestMatch(componentName.value)
        
        if (bestMatch) {
          console.log(`🎯 Archivo encontrado: ${bestMatch}.vue para ruta ${componentName.value}`)
          
          try {
            const componentModule = await import(`../../components/modules/mercados/${bestMatch}.vue`)
            
            if (componentModule.default || componentModule) {
              currentComponent.value = markRaw(componentModule.default || componentModule)
              console.log('✅ Componente cargado correctamente')
            } else {
              throw new Error('El módulo importado no tiene un export default válido')
            }
          } catch (importError) {
            console.warn(`⚠️ El archivo ${bestMatch}.vue existe pero está corrupto, mostrando placeholder`)
            
            const placeholderComponent = {
              template: `
                <div class="container-fluid mt-4">
                  <div class="alert alert-warning" role="alert">
                    <h4 class="alert-heading">⚠️ Componente en Desarrollo</h4>
                    <p>El componente <strong>${bestMatch}</strong> está actualmente en desarrollo.</p>
                    <hr>
                    <p class="mb-0">
                      <small>Módulo: Mercados | Componente: ${componentName.value}</small>
                    </p>
                  </div>
                  <div class="card">
                    <div class="card-header bg-light">
                      <h5 class="mb-0">${bestMatch.replace(/([A-Z])/g, ' $1').trim()}</h5>
                    </div>
                    <div class="card-body">
                      <p class="text-muted">Este componente será implementado próximamente.</p>
                      <div class="d-flex justify-content-between">
                        <small class="text-muted">Estado: En desarrollo</small>
                        <small class="text-muted">Módulo: Mercados</small>
                      </div>
                    </div>
                  </div>
                </div>
              `
            }
            
            currentComponent.value = markRaw(placeholderComponent)
            console.log('📋 Componente placeholder cargado')
          }
        } else {
          console.error(`❌ No se encontró componente para: ${componentName.value}`)
          throw new Error(`No se pudo encontrar el componente "${componentName.value}"`)
        }
        
      } catch (err) {
        console.error('Error cargando componente de mercados:', err)
        error.value = `Error al cargar el componente: ${err.message}`
      } finally {
        loading.value = false
      }
    }
    
    // Cargar componente al montar
    onMounted(() => {
      loadComponent()
    })
    
    // Recargar componente cuando cambie la ruta
    watch(componentName, async (newName, oldName) => {
      if (newName && newName !== oldName) {
        console.log(`🔄 Cambiando componente de ${oldName} a ${newName}`)
        // Scroll al inicio cuando cambia el submódulo
        window.scrollTo({ top: 0, behavior: 'smooth' })
        
        // Limpiar componente actual para evitar errores del DOM virtual
        currentComponent.value = null
        loading.value = true
        error.value = null
        
        // Esperar un tick para que Vue procese la limpieza
        await new Promise(resolve => setTimeout(resolve, 0))
        
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