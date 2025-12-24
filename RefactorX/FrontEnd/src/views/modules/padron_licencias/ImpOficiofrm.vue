<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" >
      <div class="module-view-icon">
        <font-awesome-icon icon="file-signature" />
      </div>
      <div class="module-view-info">
        <h1>Impresión de Oficios</h1>
        <p>Padrón de Licencias - Impresión y Registro de Oficios de Trámites</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Búsqueda de trámite -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Búsqueda de Trámite
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Trámite</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.numeroTramite"
              placeholder="Ingrese número de trámite"
              @keyup.enter="searchTramite"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Folio</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.folio"
              placeholder="Folio de trámite"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Año</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.anio"
              placeholder="Año"
              :max="new Date().getFullYear()"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchTramite"
            :disabled="!filters.numeroTramite"
          >
            <font-awesome-icon icon="search" />
            Buscar Trámite
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Información del trámite -->
    <div class="municipal-card" v-if="tramiteInfo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-alt" />
          Información del Trámite
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Datos del Trámite
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Número Trámite:</td>
                <td><strong>{{ tramiteInfo.numerotramite }}</strong></td>
              </tr>
              <tr>
                <td class="label">Folio:</td>
                <td>{{ tramiteInfo.folio || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Tipo Trámite:</td>
                <td>
                  <span class="badge-purple">{{ tramiteInfo.tipotramite || 'N/A' }}</span>
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Registro:</td>
                <td>
                  <font-awesome-icon icon="calendar" />
                  {{ formatDate(tramiteInfo.fecharegis) }}
                </td>
              </tr>
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span
                    class="badge"
                    :class="getEstadoBadgeClass(tramiteInfo.estado)"
                  >
                    {{ tramiteInfo.estado || 'N/A' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Datos del Solicitante
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Nombre:</td>
                <td>{{ tramiteInfo.solicitante || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Domicilio:</td>
                <td>{{ tramiteInfo.domicilio || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Teléfono:</td>
                <td>{{ tramiteInfo.telefono || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Correo:</td>
                <td>{{ tramiteInfo.correo || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>

        <!-- Botones de acción -->
        <div class="button-group mt-3">
          <button
            class="btn-municipal-primary"
            @click="generateOficioPreview"
          >
            <font-awesome-icon icon="eye" />
            Vista Previa de Oficio
          </button>
          <button
            class="btn-municipal-success"
            @click="printOficio"
          >
            <font-awesome-icon icon="print" />
            Imprimir Oficio
          </button>
          <button
            class="btn-municipal-info"
            @click="registerOficio"
          >
            <font-awesome-icon icon="save" />
            Registrar Impresión
          </button>
        </div>
      </div>
    </div>

    <!-- Vista previa del oficio -->
    <div class="municipal-card" v-if="showPreview && previewContent">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-pdf" />
          Vista Previa del Oficio
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="preview-container">
          <div class="document-preview" v-html="previewContent"></div>
        </div>
      </div>
    </div>

    <!-- Historial de impresiones -->
    <div class="municipal-card" v-if="tramiteInfo && impresiones.length > 0">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="history" />
          Historial de Impresiones
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="impresiones.length > 0">
            {{ impresiones.length }} registros
          </span>
        </div>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Fecha Impresión</th>
                <th>Usuario</th>
                <th>Tipo Documento</th>
                <th>Observaciones</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(imp, index) in impresiones"
                :key="index"
                @click="selectedRow = imp"
                :class="{ 'table-row-selected': selectedRow === imp }"
                class="row-hover"
              >
                <td>
                  <font-awesome-icon icon="calendar" class="text-muted" />
                  {{ formatDate(imp.fechaimpresion) }}
                </td>
                <td>{{ imp.usuario || 'N/A' }}</td>
                <td>
                  <span class="badge-purple">{{ imp.tipodocumento || 'Oficio' }}</span>
                </td>
                <td><small>{{ imp.observaciones || '-' }}</small></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <div class="toast-content">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
      </div>
      <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'ImpOficiofrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Impresión de Oficios'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import { ref, computed } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const tramiteInfo = ref(null)
const showPreview = ref(false)
const previewContent = ref('')
const impresiones = ref([])
const hasSearched = ref(false)
const selectedRow = ref(null)

// Filtros
const filters = ref({
  numeroTramite: '',
  folio: '',
  anio: new Date().getFullYear()
})

// Métodos
const searchTramite = async () => {
  if (!filters.value.numeroTramite) {
    showToast('warning', 'Ingrese un número de trámite')
    return
  }

  showLoading('Buscando trámite...', 'Por favor espere')
  hasSearched.value = true
  selectedRow.value = null

  try {
    // SP_GET_TRAMITE_INFO
    const response = await execute(
      'sp_get_tramite_info',
      'padron_licencias',
      [
        { nombre: 'p_numerotramite', valor: filters.value.numeroTramite, tipo: 'string' },
        { nombre: 'p_anio', valor: filters.value.anio, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      tramiteInfo.value = response.result[0]
      showToast('success', 'Trámite encontrado')

      // Cargar historial de impresiones
      await loadImpresiones()
    } else {
      tramiteInfo.value = null
      impresiones.value = []
      showToast('warning', 'No se encontró el trámite')
    }
  } catch (error) {
    handleApiError(error)
    tramiteInfo.value = null
    impresiones.value = []
  } finally {
    hideLoading()
  }
}

const loadImpresiones = async () => {
  try {
    // SP_IMP_OFICIO_TRAMITE_INFO (obtener historial)
    const response = await execute(
      'sp_imp_oficio_tramite_info',
      'padron_licencias',
      [
        { nombre: 'p_numerotramite', valor: filters.value.numeroTramite, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      impresiones.value = response.result
    }
  } catch (error) {
  }
}

const generateOficioPreview = () => {
  if (!tramiteInfo.value) return

  const numeroOficio = `OF-${tramiteInfo.value.numerotramite}-${filters.value.anio}`
  const fechaActual = new Date().toLocaleDateString('es-ES', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })

  previewContent.value = `
    <div style="font-family: Arial, sans-serif; padding: 40px; background: white;">
      <!-- Membrete -->
      <div style="text-align: center; border-bottom: 3px solid #ea8215; padding-bottom: 20px; margin-bottom: 30px;">
        <h3 style="color: #ea8215; margin: 0;">GOBIERNO MUNICIPAL DE GUADALAJARA</h3>
        <p style="margin: 5px 0; font-size: 14px;">Padrón de Licencias y Reglamentos</p>
      </div>

      <!-- Número de oficio y fecha -->
      <div style="text-align: right; margin-bottom: 30px;">
        <p style="margin: 5px 0;"><strong>Oficio No.:</strong> ${numeroOficio}</p>
        <p style="margin: 5px 0;"><strong>Fecha:</strong> ${fechaActual}</p>
      </div>

      <!-- Asunto -->
      <div style="margin-bottom: 20px;">
        <p><strong>ASUNTO:</strong> ${tramiteInfo.value.tipotramite || 'Trámite de Licencia'}</p>
      </div>

      <!-- Destinatario -->
      <div style="margin-bottom: 30px;">
        <p><strong>${tramiteInfo.value.solicitante || 'C. INTERESADO'}</strong></p>
        <p>P R E S E N T E</p>
      </div>

      <!-- Cuerpo del oficio -->
      <div style="text-align: justify; line-height: 1.8; margin-bottom: 30px;">
        <p>Por medio del presente, y en relación a su solicitud de trámite número <strong>${tramiteInfo.value.numerotramite}</strong>,
        folio <strong>${tramiteInfo.value.folio || 'N/A'}</strong>, me permito informarle lo siguiente:</p>

        <p style="margin-top: 20px;">En cumplimiento a lo establecido en el Reglamento Municipal correspondiente,
        y previa revisión de su expediente, se determina que el trámite se encuentra en estado:
        <strong>${tramiteInfo.value.estado || 'EN PROCESO'}</strong>.</p>

        <p style="margin-top: 20px;"><strong>Datos del Trámite:</strong></p>
        <ul style="list-style: none; padding-left: 20px;">
          <li><strong>Número de Trámite:</strong> ${tramiteInfo.value.numerotramite}</li>
          <li><strong>Folio:</strong> ${tramiteInfo.value.folio || 'N/A'}</li>
          <li><strong>Tipo:</strong> ${tramiteInfo.value.tipotramite || 'N/A'}</li>
          <li><strong>Fecha de Registro:</strong> ${formatDate(tramiteInfo.value.fecharegis)}</li>
          <li><strong>Domicilio:</strong> ${tramiteInfo.value.domicilio || 'N/A'}</li>
        </ul>

        <p style="margin-top: 20px;">Sin otro particular por el momento, quedo de usted.</p>
      </div>

      <!-- Firma -->
      <div style="margin-top: 80px; text-align: center;">
        <div style="border-top: 2px solid #333; width: 300px; margin: 0 auto; padding-top: 10px;">
          <p style="margin: 5px 0;"><strong>ATENTAMENTE</strong></p>
          <p style="margin: 5px 0;">Departamento de Padrón de Licencias</p>
        </div>
      </div>

      <!-- Pie de página -->
      <div style="margin-top: 50px; text-align: center; font-size: 11px; color: #666;">
        <p>Documento generado el ${new Date().toLocaleDateString('es-ES')} a las ${new Date().toLocaleTimeString('es-ES')}</p>
      </div>
    </div>
  `
  showPreview.value = true
  showToast('success', 'Vista previa generada')
}

const printOficio = async () => {
  const result = await Swal.fire({
    title: '¿Imprimir oficio?',
    text: '¿Desea imprimir el oficio del trámite?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, imprimir',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    generateOficioPreview()
    setTimeout(() => {
      window.print()
      showToast('success', 'Documento enviado a impresión')
      // Registrar la impresión automáticamente
      registerOficio()
    }, 500)
  }
}

const registerOficio = async () => {
  showLoading('Registrando impresión...', 'Por favor espere')

  try {
    // SP_IMP_OFICIO_REGISTER
    const response = await execute(
      'sp_imp_oficio_register',
      'padron_licencias',
      [
        { nombre: 'p_numerotramite', valor: filters.value.numeroTramite, tipo: 'string' },
        { nombre: 'p_tipodocumento', valor: 'OFICIO', tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' },
        { nombre: 'p_observaciones', valor: 'Impresión generada', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showToast('success', 'Impresión registrada correctamente')
      // Recargar historial
      await loadImpresiones()
    } else {
      showToast('warning', 'No se pudo registrar la impresión')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const clearFilters = () => {
  filters.value = {
    numeroTramite: '',
    folio: '',
    anio: new Date().getFullYear()
  }
  tramiteInfo.value = null
  showPreview.value = false
  previewContent.value = ''
  impresiones.value = []
  hasSearched.value = false
  selectedRow.value = null
}

// Utilidades
const getEstadoBadgeClass = (estado) => {
  const estados = {
    'APROBADO': 'badge-success',
    'EN PROCESO': 'badge-warning',
    'RECHAZADO': 'badge-danger',
    'CANCELADO': 'badge-secondary'
  }
  return estados[estado] || 'badge-secondary'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  } catch {
    return 'Fecha inválida'
  }
}
</script>
