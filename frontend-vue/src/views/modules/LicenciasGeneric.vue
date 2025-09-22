<template>
  <div class="module-page">
    
    <!-- Mostrar loading mientras se carga el componente -->
    <div v-if="loadingComponent" class="text-center py-4">
      <div class="spinner-border text-primary"></div>
      <p class="mt-2">Cargando componente...</p>
    </div>
    
    <!-- Cargar componente específico si existe y está cargado -->
    <component v-else-if="loadedComponent" :is="loadedComponent" />
    
    <!-- Mostrar interfaz genérica para módulos sin implementación específica -->
    <div v-else class="generic-interface">
      <div class="container-fluid">
        <div class="alert alert-primary mb-4">
          <h4 class="alert-heading">📋 {{ moduleTitle }}</h4>
          <p class="mb-0">{{ moduleDescription }}</p>
          <hr>
          <p class="mb-0">
            <small><strong>Módulo:</strong> Licencias | <strong>Componente:</strong> {{ currentSubmodule }}</small>
          </p>
        </div>

        <div class="row">
          <div class="col-lg-8">
            <div class="card">
              <div class="card-header">
                <h5 class="mb-0">{{ moduleTitle }}</h5>
              </div>
              <div class="card-body">
                <div class="alert alert-info">
                  <h6 class="alert-heading">🔧 Módulo en Desarrollo</h6>
                  <p class="mb-2">Este módulo está disponible pero aún no se pudo cargar el componente.</p>
                  <p class="mb-0"><strong>Componente esperado:</strong> <code>{{ currentSubmodule }}.vue</code></p>
                </div>
                
                <div class="mt-4">
                  <h6>Información del Sistema</h6>
                  <div class="table-responsive">
                    <table class="table table-sm">
                      <tr>
                        <td><strong>Módulo:</strong></td>
                        <td>Licencias</td>
                      </tr>
                      <tr>
                        <td><strong>Submódulo:</strong></td>
                        <td>{{ currentSubmodule }}</td>
                      </tr>
                      <tr>
                        <td><strong>Ruta:</strong></td>
                        <td><code>{{ currentRoute }}</code></td>
                      </tr>
                      <tr>
                        <td><strong>Fecha:</strong></td>
                        <td>{{ currentDate }}</td>
                      </tr>
                    </table>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="col-lg-4">
            <div class="card">
              <div class="card-header">
                <h6 class="mb-0">Estado del Módulo</h6>
              </div>
              <div class="card-body">
                <div class="d-flex align-items-center mb-3">
                  <div class="badge badge-warning mr-2">En Desarrollo</div>
                </div>
                <p class="small text-muted mb-2">
                  Este módulo forma parte del sistema de licencias.
                </p>
                <div class="mt-3">
                  <h6 class="small font-weight-bold">Funcionalidades Esperadas:</h6>
                  <ul class="small text-muted mb-0">
                    <li>Formularios de gestión</li>
                    <li>Consultas y reportes</li>
                    <li>Validación de datos</li>
                    <li>Integración con backend</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LicenciasGeneric',
  data() {
    return {
      loadedComponent: null,
      loadingComponent: false
    }
  },
  
  computed: {
    currentSubmodule() {
      return this.$route.params.submodule?.toLowerCase()
    },
    
    moduleTitle() {
      const submodule = this.currentSubmodule
      if (!submodule) return 'Licencias'
      
      // Transformar nombre del archivo a título legible
      return submodule
        .split(/[_-]/)
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ')
    },
    
    moduleDescription() {
      const descriptions = {
        // 🆕 NUEVOS COMPONENTES DE MODERNIZACIÓN
        'perfilesusuariomoderno': '🆕 NUEVO: Separación granular de perfiles (Padrón, Licencias, Ingresos)',
        'catalogogirosimportes': '🆕 NUEVO: Catálogo de giros con gestión de importes para usuarios ingresos',
        'permisosprovisionales': '🆕 NUEVO: Sistema de permisos temporales (Espectáculos, Licencias, Anuncios)',
        'sistemaconvenios': '🆕 NUEVO: Sistema integral ABC de convenios, intereses y parcialidades',
        // Componentes existentes
        'empleadoslistado': 'Gestión y consulta de empleados del sistema',
        'agendavisitasfrm': 'Gestión y consulta de agenda de visitas programadas',
        'bajaanunciofrm': '* Administración de baja de anuncios publicitarios',
        'bajalicenciafrm': 'Gestión de baja de licencias comerciales',
        'bloquearanunciorm': 'Bloqueo y control de anuncios publicitarios',
        'bloquearlicenciafrm': 'Bloqueo temporal de licencias',
        'bloqueartramitefrm': 'Control de bloqueo de trámites',
        'catalogogirosfrm': 'Catálogo y administración de giros comerciales',
        'busque': 'Sistema de búsqueda general de licencias',
        'constanciafrm': '* Gestión y consulta de constancias de licencias',
        'consultapredial': '* Consulta de información predial',
        'consultaanunciofrm': '* Consulta y gestión de anuncios publicitarios',
        'consultatramitefrm': '* Consulta y gestión de trámites de control',
        'consultausuariosfrm': '* Consulta y administración de usuarios del sistema',
        'consultaLicenciafrm': '* Consulta y gestión de licencias comerciales',
        'cruces': '* Sistema de cruces y validaciones',
        'dependenciasfrm': '* Gestión de dependencias administrativas',
        'dictamenfrm': '* Generación y consulta de dictámenes',
        'empresasfrm': '* Administración de empresas y comercios',
        'estatusfrm': '* Control de estatus de trámites',
        'fechasegfrm': '* Gestión de fechas de seguimiento',
        'formatosecologiafrm': '* Formatos y requisitos de ecología',
        'girosdconadeudofrm': '* Gestión de giros con adeudos',
        'licenciasvigentesfrm': '* Control de licencias vigentes',
        'gestionhologramasfrm': 'Gestión de hologramas',
        'gruposanunciosfrm': 'Administración de grupos de anuncios',
        'default': 'Módulo del sistema de licencias'
      }
      
      return descriptions[this.currentSubmodule] || descriptions.default
    },
    
    currentRoute() {
      return this.$route.path
    },
    
    currentDate() {
      return new Date().toLocaleDateString('es-ES')
    },

    hasSpecificImplementation() {
      return {
        // 🆕 NUEVOS COMPONENTES DE MODERNIZACIÓN
        'perfilesusuariomoderno': 'PerfilesUsuarioModerno.vue',
        'catalogogirosimportes': 'CatalogoGirosImportes.vue',
        'permisosprovisionales': 'PermisosProvisionales.vue',
        'sistemaconvenios': 'SistemaConvenios.vue',
        // Componentes existentes
        'empleadoslistado': 'EmpleadosListado.vue',
        'agendavisitasfrm': 'Agendavisitasfrm.vue',
        'bajaanunciofrm': 'bajaAnunciofrm.vue',
        'bajalicenciafrm': 'bajaLicenciafrm.vue',
        'bloquearanunciorm': 'BloquearAnunciorm.vue',
        'bloquearlicenciafrm': 'BloquearLicenciafrm.vue',
        'bloqueartramitefrm': 'BloquearTramitefrm.vue',
        'bloqueodomiciliosfrm': 'bloqueoDomiciliosfrm.vue',
        'bloqueorfcfrm': 'bloqueoRFCfrm.vue',
        'buscagirofrm': 'buscagirofrm.vue',
        'busque': 'busque.vue',
        'busquedaactividadfrm': 'BusquedaActividadFrm.vue',
        'busquedascianfrm': 'BusquedaScianFrm.vue',
        'cancelatramitefrm': 'cancelaTramitefrm.vue',
        'carga': 'carga.vue',
        'cargadatosfrm': 'cargadatosfrm.vue',
        'carga_imagen': 'carga_imagen.vue',
        'cartonva': 'cartonva.vue',
        'catalogoactividadesfrm': 'CatalogoActividadesFrm.vue',
        'catalogogirosfrm': 'catalogogirosfrm.vue',
        'catastrodm': 'CatastroDM.vue',
        'catrequisitos': 'CatRequisitos.vue',
        'certificacionesfrm': 'certificacionesfrm.vue',
        'consanun400frm': 'consAnun400frm.vue',
        'conslic400frm': 'consLic400frm.vue',
        'constanciafrm': 'constanciafrm.vue',
        'constancianooficialfrm': 'constanciaNoOficialfrm.vue',
        'consultaanunciofrm': 'consultaAnunciofrm.vue',
        'consultaLicenciafrm': 'consultaLicenciafrm.vue',
        'consultalicenciafrm': 'consultaLicenciafrm.vue',
        'consultapredial': 'consultapredial.vue',
        'consultatramitefrm': 'ConsultaTramitefrm.vue',
        'consultausuariosfrm': 'consultausuariosfrm.vue',
        'cruces': 'Cruces.vue',
        'dependenciasfrm': 'dependenciasFrm.vue',
        'dictamenfrm': 'dictamenfrm.vue',
        'dictamenusodesuelo': 'dictamenusodesuelo.vue',
        'doctosfrm': 'doctosfrm.vue',
        'empresasfrm': 'empresasfrm.vue',
        'estatusfrm': 'estatusfrm.vue',
        'fechasegfrm': 'fechasegfrm.vue',
        'firma': 'firma.vue',
        'firmausuario': 'firmausuario.vue',
        'formabuscalle': 'formabuscalle.vue',
        'formabuscolonia': 'formabuscolonia.vue',
        'formatosecologiafrm': 'formatosEcologiafrm.vue',
        'frmimplicenciareglamentada': 'frmImpLicenciaReglamentada.vue',
        'frmselcalle': 'frmselcalle.vue',
        'gestionhologramasfrm': 'gestionHologramasfrm.vue',
        'girosdconadeudofrm': 'GirosDconAdeudofrm.vue',
        'girosvigentesctexgirofrm': 'girosVigentesCteXgirofrm.vue',
        'grs_dlg': 'grs_dlg.vue',
        'gruposanunciosabcfrm': 'GruposAnunciosAbcfrm.vue',
        'gruposanunciosfrm': 'gruposAnunciosfrm.vue',
        'gruposlicenciasabcfrm': 'GruposLicenciasAbcfrm.vue',
        'gruposlicenciasfrm': 'gruposLicenciasfrm.vue',
        'hastafrm': 'Hastafrm.vue',
        'h_bloqueodomiciliosfrm': 'h_bloqueoDomiciliosfrm.vue',
        'implicenciareglamentadafrm': 'ImpLicenciaReglamentadaFrm.vue',
        'impoficiofrm': 'ImpOficiofrm.vue',
        'imprecibofrm': 'ImpRecibofrm.vue',
        'impsolinspeccionfrm': 'impsolinspeccionfrm.vue',
        'licenciasvigentesfrm': 'LicenciasVigentesfrm.vue',
        'ligaanunciofrm': 'ligaAnunciofrm.vue',
        'ligarequisitos': 'LigaRequisitos.vue',
        'modlicadeudofrm': 'modlicAdeudofrm.vue',
        'modlicfrm': 'modlicfrm.vue',
        'modtramitefrm': 'modtramitefrm.vue',
        'observacionfrm': 'observacionfrm.vue',
        'prepagofrm': 'prepagofrm.vue',
        'privilegios': 'privilegios.vue',
        'prophologramasfrm': 'prophologramasfrm.vue',
        'propuestatab': 'Propuestatab.vue',
        'psplash': 'psplash.vue',
        'reactivatramite': 'ReactivaTramite.vue',
        'reghfrm': 'regHfrm.vue',
        'registrosolicitudform': 'RegistroSolicitudForm.vue',
        'regsolicfrm': 'regsolicfrm.vue',
        'regsolicfrm_manual': 'regsolicfrm_manual.vue',
        'repdoc': 'repdoc.vue',
        'repestadisticoslicfrm': 'repEstadisticosLicfrm.vue',
        'repestado': 'repestado.vue',
        'reporteanunexcelfrm': 'ReporteAnunExcelfrm.vue',
        'repsuspendidasfrm': 'repsuspendidasfrm.vue',
        'responsivafrm': 'Responsivafrm.vue',
        'revisionesfrm': 'revisionesfrm.vue',
        'semaforo': 'Semaforo.vue',
        'sfrm_chgfirma': 'sfrm_chgfirma.vue',
        'sfrm_chgpass': 'sfrm_chgpass.vue',
        'sgcv2': 'SGCv2.vue',
        'splash': 'splash.vue',
        'tdmconection': 'TDMConection.vue',
        'tipobloqueofrm': 'tipobloqueofrm.vue',
        'tramitebajaanun': 'TramiteBajaAnun.vue',
        'tramitebajalic': 'TramiteBajaLic.vue',
        'unidadimg': 'UnidadImg.vue',
        'webbrowser': 'webBrowser.vue',
        'zonaanuncio': 'ZonaAnuncio.vue',
        'zonalicencia': 'ZonaLicencia.vue'
      }
    }
  },

  methods: {
    async loadComponent() {
      const submodule = this.currentSubmodule
      console.log(`🚀 loadComponent called with submodule: "${submodule}"`)
      
      if (!submodule) {
        console.log(`⚠️ No submodule provided`)
        this.loadedComponent = null
        return
      }
      
      const hasImplementation = this.hasSpecificImplementation[submodule]
      console.log(`🔍 Checking implementation for "${submodule}":`, hasImplementation)
      
      if (!hasImplementation) {
        console.log(`❌ No implementation found for "${submodule}"`)
        this.loadedComponent = null
        return
      }

      this.loadingComponent = true
      this.loadedComponent = null

      try {
        // Carga dinámica para todos los componentes
        const fileName = hasImplementation
        const componentPath = `../../components/modules/licencias/${fileName}`
        console.log(`🔄 Importing component from: ${componentPath}`)

        const component = await import(/* @vite-ignore */ `../../components/modules/licencias/${fileName}`)
        console.log(`✅ Component import successful:`, component)
        console.log(`✅ Component default:`, component.default)

        if (component.default) {
          this.loadedComponent = component.default
          console.log(`✅ loadedComponent set successfully`)
        } else {
          console.error(`❌ component.default is null/undefined`)
          this.loadedComponent = null
        }
      } catch (error) {
        console.error(`❌ Error importing component "${submodule}":`, error)
        console.error(`❌ Error details:`, error.message, error.stack)
        this.loadedComponent = null
      } finally {
        this.loadingComponent = false
        console.log(`🏁 loadComponent finished. loadedComponent:`, !!this.loadedComponent)
      }
    }
  },

  mounted() {
    console.log('🎯 LicenciasGeneric mounted, loading component...')
    this.loadComponent()
  },

  watch: {
    currentSubmodule: {
      immediate: true,
      handler() {
        console.log('📍 Route changed to:', this.currentSubmodule)
        // Scroll al inicio cuando cambia el submódulo
        window.scrollTo({ top: 0, behavior: 'smooth' })
        this.loadComponent()
      }
    }
  }
}
</script>

<style scoped>
.module-page {
  padding: 1rem;
}

.real-component-info {
  max-width: 1200px;
  margin: 0 auto;
}

.generic-interface {
  background-color: #f8f9fa;
  min-height: 80vh;
  padding: 1rem;
}

.card {
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  border: 1px solid #dee2e6;
}

.alert-heading {
  color: #0c5460;
}

.badge {
  font-size: 0.75rem;
}

.table td {
  border-top: 1px solid #dee2e6;
}

.bg-gradient-to-r {
  background: linear-gradient(to right, #10b981, #3b82f6);
}

.text-green-100 {
  color: #dcfce7;
}

.border-green-500 {
  border-color: #10b981;
}

.text-green-600 {
  color: #059669;
}

.text-green-700 {
  color: #047857;
}

.text-blue-700 {
  color: #1d4ed8;
}

.bg-green-50 {
  background-color: #f0fdf4;
}

.bg-blue-50 {
  background-color: #eff6ff;
}

.border-green-200 {
  border-color: #bbf7d0;
}
</style>