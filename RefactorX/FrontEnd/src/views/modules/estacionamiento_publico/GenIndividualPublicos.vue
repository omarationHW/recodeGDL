<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-circle-plus" /></div>
      <div class="module-view-info">
        <h1>Generación Individual — Remesa</h1>
        <p>Agregar por placa/folio y generar archivo</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loadingAdd" @click="add"><font-awesome-icon icon="plus" /> Agregar</button>
        <button class="btn-municipal-primary" :disabled="loadingFile" @click="generarArchivo"><font-awesome-icon icon="download" /> Generar Archivo</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Opción</label><select class="municipal-form-control" v-model.number="opcion"><option :value="0">Placa</option><option :value="1">Placa + Folios</option><option :value="2">Año + Folios</option></select></div>
            <div class="form-group"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="placa" /></div>
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="axo" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Folios (coma)</label><input class="municipal-form-control" v-model="folios" placeholder="Ej. 123,456" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Remesa</label><input class="municipal-form-control" v-model="remesa" /></div>
          </div>
          <div v-if="loadingAdd" class="spinner-border" role="status"></div>
          <div v-if="loadingFile" class="spinner-border" role="status"></div>
          <pre v-if="output" class="text-muted">{{ output }}</pre>
        </div>
      </div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - GenIndividualPublicos"
    >
      <h3>Gen Individual Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'GenIndividualPublicos'"
      :moduleName="'estacionamiento_publico'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, nextTick } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const opcion = ref(0)
const placa = ref('')
const axo = ref(new Date().getFullYear())
const folios = ref('')
const remesa = ref('')
const loadingAdd = ref(false)
const loadingFile = ref(false)
const output = ref('')

async function add() {
  // Validar según opción
  if (opcion.value === 0 && !placa.value.trim()) {
    showToast('warning', 'Ingrese la placa')
    return
  }
  if (opcion.value === 1 && (!placa.value.trim() || !folios.value.trim())) {
    showToast('warning', 'Ingrese placa y folios')
    return
  }
  if (opcion.value === 2 && !folios.value.trim()) {
    showToast('warning', 'Ingrese los folios')
    return
  }

  showLoading('Agregando...', 'Procesando registro')
  loadingAdd.value = true
  try {
    const params = [
      { nombre: 'p_opcion', valor: opcion.value, tipo: 'integer' },
      { nombre: 'p_placa', valor: placa.value.toUpperCase(), tipo: 'string' },
      { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_folio', valor: folios.value, tipo: 'string' },
      { nombre: 'p_remesa', valor: remesa.value, tipo: 'string' }
    ]
    const resp = await execute('sp_gen_individual_add', BASE_DB, params, '', null, SCHEMA)

    if (resp?.success !== false) {
      hideLoading()
      await nextTick()
      await Swal.fire({
        icon: 'success',
        title: 'Registro Agregado',
        text: 'El registro se agregó correctamente a la remesa',
        timer: 2500,
        timerProgressBar: true,
        showConfirmButton: false
      })
    }
  } catch (e) {
    handleApiError(e)
    hideLoading()
  } finally {
    loadingAdd.value = false
  }
}

async function generarArchivo() {
  if (!remesa.value.trim()) {
    showToast('warning', 'Ingrese el número de remesa')
    return
  }

  // Confirmación con SweetAlert2
  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Generación',
    html: `<p>¿Generar archivo para la remesa?</p>
      <p><strong>Remesa:</strong> ${remesa.value}</p>`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, generar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Generando...', 'Creando archivo')
  loadingFile.value = true
  output.value = ''
  try {
    const params = [{ nombre: 'p_remesa', valor: remesa.value, tipo: 'string' }]
    const resp = await execute('sp_gen_individual_generate_file', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    const rows = Array.isArray(data) ? data : []
    const lines = rows.map(r => Object.values(r).join('|')).join('\n')
    output.value = lines || 'Sin datos para generar'

    hideLoading()
    await nextTick()

    if (rows.length > 0) {
      await Swal.fire({
        icon: 'success',
        title: 'Archivo Generado',
        html: `<p>Se generaron <strong>${rows.length}</strong> registros</p>`,
        timer: 2500,
        timerProgressBar: true,
        showConfirmButton: false
      })
    } else {
      await Swal.fire({
        icon: 'info',
        title: 'Sin Datos',
        text: 'No hay datos para generar en esta remesa',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (e) {
    handleApiError(e)
    hideLoading()
  } finally {
    loadingFile.value = false
  }
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

