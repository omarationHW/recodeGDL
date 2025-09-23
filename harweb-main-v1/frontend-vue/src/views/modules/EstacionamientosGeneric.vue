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
    
    <component v-else-if="currentComponent" :is="currentComponent" />
    
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
  name: 'EstacionamientosGeneric',
  setup() {
    const route = useRoute()
    const currentComponent = ref(null)
    const loading = ref(true)
    const error = ref(null)
    
    const componentName = computed(() => {
      return route.params.submodule || ''
    })
    
    // Lista de archivos reales disponibles en el módulo estacionamientos
    const availableFiles = [
      "Acceso", "AplicaPgo_DivAdmin", "Bja_Multiple", "Bja_Multiple_Ind", "Cga_ArcEdoEx", "ConsGral", "ConsRemesas", "DM_Crbos", "DsDBGasto", "Dspasswords", "frmMetrometers", "Gen_ArcAltas", "Gen_ArcDiario", "Gen_Individual", "Gen_Individual_b", "Gen_PgosBanorte", "mensaje", "Reactiva_Folios", "Reportes_Folios", "sdmWebService", "sfolios_alta", "sfrmMetrometers", "sfrmprediocarto", "sfrm_abc_propietario", "sfrm_alta_ubicaciones", "sfrm_aspecto", "sfrm_chg_autorizadescto", "sfrm_consultapublicos", "sFrm_consulta_folios", "sFrm_datos_oficio", "sfrm_excConsulta", "sfrm_EXC_alta", "sfrm_exc_mod_contrato", "sFrm_menu", "sfrm_modif_folios", "sfrm_nva_calco", "sfrm_pagosestadorel", "sFrm_pasar_padron", "sfrm_pdfviewer", "sfrm_prop_exclusivo", "sfrm_reportescalco", "SFRM_REPORTES_EXEC", "sfrm_report_pagos", "sfrm_rep_folio", "sfrm_transfolios", "sFrm_trans_exclu", "sfrm_trans_pub", "sfrm_tr_estado_mpio", "sFrm_UpExclus", "sfrm_up_pagos", "sfrm_valet_paso", "spubActualizacionfrm", "spublicosnewfrm", "spubreports", "sqrp_esta01", "sqrp_publicos", "sQRp_relacion_folios", "sQRt_imp_padron", "srfrm_conci_banorte", "Unit1", "UNIT9"
    ]

    // Mapeo de componentes que sabemos que tienen implementaciones específicas
    const hasSpecificImplementation = {
      'acceso': 'Acceso.vue',
      'aplicapgo_divadmin': 'AplicaPgo_DivAdmin.vue',
      'bja_multiple': 'Bja_Multiple.vue',
      'bja_multiple_ind': 'Bja_Multiple_Ind.vue',
      'cga_arcedoex': 'Cga_ArcEdoEx.vue',
      'consgral': 'ConsGral.vue',
      'consremesas': 'ConsRemesas.vue',
      'dm_crbos': 'DM_Crbos.vue',
      'dsdbgasto': 'DsDBGasto.vue',
      'dspasswords': 'Dspasswords.vue',
      'frmmetrometers': 'frmMetrometers.vue',
      'gen_arcaltas': 'Gen_ArcAltas.vue',
      'gen_arcdiario': 'Gen_ArcDiario.vue',
      'gen_individual': 'Gen_Individual.vue',
      'gen_individual_b': 'Gen_Individual_b.vue',
      'gen_pgosbanorte': 'Gen_PgosBanorte.vue',
      'mensaje': 'mensaje.vue',
      'reactiva_folios': 'Reactiva_Folios.vue',
      'reportes_folios': 'Reportes_Folios.vue',
      'sdmwebservice': 'sdmWebService.vue',
      'sfolios_alta': 'sfolios_alta.vue',
      'sfrmmetrometers': 'sfrmMetrometers.vue',
      'sfrmprediocarto': 'sfrmprediocarto.vue',
      'sfrm_abc_propietario': 'sfrm_abc_propietario.vue',
      'sfrm_alta_ubicaciones': 'sfrm_alta_ubicaciones.vue',
      'sfrm_aspecto': 'sfrm_aspecto.vue',
      'sfrm_chg_autorizadescto': 'sfrm_chg_autorizadescto.vue',
      'sfrm_consultapublicos': 'sfrm_consultapublicos.vue',
      'sfrm_consulta_folios': 'sFrm_consulta_folios.vue',
      'sfrm_datos_oficio': 'sFrm_datos_oficio.vue',
      'sfrm_excconsulta': 'sfrm_excConsulta.vue',
      'sfrm_exc_alta': 'sfrm_EXC_alta.vue',
      'sfrm_exc_mod_contrato': 'sfrm_exc_mod_contrato.vue',
      'sfrm_menu': 'sFrm_menu.vue',
      'sfrm_modif_folios': 'sfrm_modif_folios.vue',
      'sfrm_nva_calco': 'sfrm_nva_calco.vue',
      'sfrm_pagosestadorel': 'sfrm_pagosestadorel.vue',
      'sfrm_pasar_padron': 'sFrm_pasar_padron.vue',
      'sfrm_pdfviewer': 'sfrm_pdfviewer.vue',
      'sfrm_prop_exclusivo': 'sfrm_prop_exclusivo.vue',
      'sfrm_reportescalco': 'sfrm_reportescalco.vue',
      'sfrm_reportes_exec': 'SFRM_REPORTES_EXEC.vue',
      'sfrm_report_pagos': 'sfrm_report_pagos.vue',
      'sfrm_rep_folio': 'sfrm_rep_folio.vue',
      'sfrm_transfolios': 'sfrm_transfolios.vue',
      'sfrm_trans_exclu': 'sFrm_trans_exclu.vue',
      'sfrm_trans_pub': 'sfrm_trans_pub.vue',
      'sfrm_tr_estado_mpio': 'sfrm_tr_estado_mpio.vue',
      'sfrm_upexclus': 'sFrm_UpExclus.vue',
      'sfrm_up_pagos': 'sfrm_up_pagos.vue',
      'sfrm_valet_paso': 'sfrm_valet_paso.vue',
      'spubactualizacionfrm': 'spubActualizacionfrm.vue',
      'spublicosnewfrm': 'spublicosnewfrm.vue',
      'spubreports': 'spubreports.vue',
      'sqrp_esta01': 'sqrp_esta01.vue',
      'sqrp_publicos': 'sqrp_publicos.vue',
      'sqrp_relacion_folios': 'sQRp_relacion_folios.vue',
      'sqrt_imp_padron': 'sQRt_imp_padron.vue',
      'srfrm_conci_banorte': 'srfrm_conci_banorte.vue',
      'unit1': 'Unit1.vue',
      'unit9': 'UNIT9.vue'
    }

    // Función para encontrar el archivo más similar
    const findBestMatch = (searchName) => {
      const search = searchName.toLowerCase()
      
      // Buscar en mappings específicos primero
      if (hasSpecificImplementation[search]) {
        return hasSpecificImplementation[search].replace('.vue', '')
      }
      
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
            const componentModule = await import(`../../components/modules/estacionamientos/${bestMatch}.vue`)
            
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
                      <small>Módulo: Estacionamientos | Componente: ${componentName.value}</small>
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
                        <small class="text-muted">Módulo: Estacionamientos</small>
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
        console.error('Error cargando componente de estacionamientos:', err)
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
    watch(componentName, (newName, oldName) => {
      if (newName && newName !== oldName) {
        console.log(`🔄 Cambiando componente de ${oldName} a ${newName}`)
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