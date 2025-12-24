<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="plus-circle" />
      </div>
      <div class="module-view-info">
        <h1>Alta de Locales</h1>
        <p>Otras Obligaciones - Rastro - Alta de nuevos contratos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="plus" /> Crear Nuevo Local</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número:</label>
              <input
                type="text"
                v-model="formData.numero"
                class="municipal-form-control"
                placeholder="Número"
                maxlength="6"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Letra:</label>
              <input
                type="text"
                v-model="formData.letra"
                class="municipal-form-control"
                placeholder="Letra"
                maxlength="2"
              />
            </div>
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Concesionario:</label>
              <input
                type="text"
                v-model="formData.concesionario"
                class="municipal-form-control"
                maxlength="255"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group" style="flex: 3;">
              <label class="municipal-form-label">Ubicación:</label>
              <input
                type="text"
                v-model="formData.ubicacion"
                class="municipal-form-control"
                maxlength="255"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Superficie (m²):</label>
              <input
                type="number"
                v-model.number="formData.superficie"
                class="municipal-form-control"
                :min="0"
                step="0.01"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Licencia:</label>
              <input
                type="number"
                v-model.number="formData.licencia"
                class="municipal-form-control"
                :min="0"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo Local:</label>
              <select v-model="formData.tipoLocal" class="municipal-form-control">
                <option value="">Seleccione...</option>
                <option v-for="tipo in tiposLocal" :key="tipo.cve_tab" :value="tipo.descripcion">
                  {{ tipo.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina:</label>
              <input
                type="number"
                v-model.number="formData.oficina"
                class="municipal-form-control"
                :min="0"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sector:</label>
              <input
                type="text"
                v-model="formData.sector"
                class="municipal-form-control"
                maxlength="10"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Zona:</label>
              <input
                type="number"
                v-model.number="formData.zona"
                class="municipal-form-control"
                :min="0"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año Inicio:</label>
              <input
                type="number"
                v-model.number="formData.anioInicio"
                class="municipal-form-control"
                :min="2020"
                :max="2099"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mes Inicio:</label>
              <select v-model.number="formData.mesInicio" class="municipal-form-control">
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">{{ mes.label }}</option>
              </select>
            </div>
          </div>

          <div class="button-group mt-3">
            <button class="btn-municipal-primary" @click="handleGuardar">
              <font-awesome-icon icon="save" /> Aplicar Alta
            </button>
            <button class="btn-municipal-secondary" @click="handleLimpiar">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentacion -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'RNuevos'"
      :moduleName="'otras_obligaciones'"
      :docType="docType"
      :title="'Alta de Locales'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const BASE_DB = 'otras_obligaciones'
const router = useRouter()
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

// Documentacion y Ayuda
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

const tiposLocal = ref([])

const formData = reactive({
  numero: '',
  letra: '',
  concesionario: '',
  ubicacion: '',
  superficie: 0,
  licencia: 0,
  tipoLocal: '',
  oficina: 1,
  sector: '',
  zona: 1,
  anioInicio: new Date().getFullYear(),
  mesInicio: new Date().getMonth() + 1
})

const meses = [
  { value: 1, label: '01-Enero' },
  { value: 2, label: '02-Febrero' },
  { value: 3, label: '03-Marzo' },
  { value: 4, label: '04-Abril' },
  { value: 5, label: '05-Mayo' },
  { value: 6, label: '06-Junio' },
  { value: 7, label: '07-Julio' },
  { value: 8, label: '08-Agosto' },
  { value: 9, label: '09-Septiembre' },
  { value: 10, label: '10-Octubre' },
  { value: 11, label: '11-Noviembre' },
  { value: 12, label: '12-Diciembre' }
]

const loadTiposLocal = async () => {
  try {
    const response = await execute(
      'sp_otras_oblig_get_tablas',
      BASE_DB,
      [{ nombre: 'par_tab', valor: 3, tipo: 'integer' }],
      'guadalajara'
    )

    if (response?.result?.length > 0) {
      tiposLocal.value = response.result
      if (tiposLocal.value.length > 0) {
        formData.tipoLocal = tiposLocal.value[0].descripcion
      }
    }
  } catch (error) {
    handleApiError(error)
  }
}

const handleGuardar = async () => {
  const currentYear = new Date().getFullYear()
  const previousYear = currentYear - 1

  if (!formData.numero || formData.numero.trim() === '') {
    showToast('warning', 'Falta el número de local')
    return
  }

  if (!formData.concesionario || formData.concesionario.trim() === '') {
    showToast('warning', 'Falta el concesionario')
    return
  }

  if (!formData.superficie || formData.superficie === 0) {
    showToast('warning', 'Falta la superficie')
    return
  }

  if (formData.anioInicio !== currentYear && formData.anioInicio !== previousYear) {
    showToast('warning', 'El año debe ser el actual o el anterior')
    return
  }

  if (!formData.tipoLocal) {
    showToast('warning', 'Debe seleccionar un tipo de local')
    return
  }

  showLoading('Guardando local...')

  try {
    const control = `${formData.numero}${formData.letra ? '-' + formData.letra : ''}`
    const tipoLocal = (formData.tipoLocal || '').substring(0, 100)

    const response = await execute(
      'sp_ins34_rastro_01',
      BASE_DB,
      [
        { nombre: 'par_tabla', valor: 3, tipo: 'integer' },
        { nombre: 'par_control', valor: control, tipo: 'varchar' },
        { nombre: 'par_conces', valor: formData.concesionario, tipo: 'varchar' },
        { nombre: 'par_ubica', valor: formData.ubicacion || '', tipo: 'varchar' },
        { nombre: 'par_sup', valor: formData.superficie, tipo: 'numeric' },
        { nombre: 'par_axo_ini', valor: formData.anioInicio, tipo: 'integer' },
        { nombre: 'par_mes_ini', valor: formData.mesInicio, tipo: 'integer' },
        { nombre: 'par_ofna', valor: formData.oficina, tipo: 'integer' },
        { nombre: 'par_sector', valor: formData.sector || '', tipo: 'varchar' },
        { nombre: 'par_zona', valor: formData.zona, tipo: 'integer' },
        { nombre: 'par_lic', valor: formData.licencia, tipo: 'integer' },
        { nombre: 'par_descrip', valor: tipoLocal, tipo: 'varchar' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response?.result?.[0]) {
      const result = response.result[0]

      if (result.expression === 0) {
        await Swal.fire({
          icon: 'success',
          title: 'Local creado',
          text: result.expression_1 || 'Se ejecutó correctamente la creación del Local/Concesión',
          confirmButtonColor: '#ea8215'
        })
        handleLimpiar()
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: result.expression_1 || 'Error al crear local',
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const handleLimpiar = () => {
  Object.assign(formData, {
    numero: '',
    letra: '',
    concesionario: '',
    ubicacion: '',
    superficie: 0,
    licencia: 0,
    tipoLocal: tiposLocal.value.length > 0 ? tiposLocal.value[0].descripcion : '',
    oficina: 1,
    sector: '',
    zona: 1,
    anioInicio: new Date().getFullYear(),
    mesInicio: new Date().getMonth() + 1
  })
}

const goBack = () => router.push('/otras-obligaciones/menu')

onMounted(() => {
  loadTiposLocal()
})
</script>

<style scoped>
/* Estilos en municipal-theme.css */
</style>
