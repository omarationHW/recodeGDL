<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="plus-circle" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Nuevos</h1>
        <p>Otras Obligaciones - Alta de nuevos contratos</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda y documentación del módulo"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-secondary"
          @click="goBack"
          :disabled="isLoading"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="plus" />
            Crear Nuevo Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="hashtag" class="me-1" />
                Control:
                <span class="required">*</span>
              </label>
              <div class="d-flex gap-2">
                <input
                  type="text"
                  v-model="formData.numero"
                  class="municipal-form-control"
                  placeholder="Número"
                  maxlength="3"
                  style="flex: 1;"
                />
                <span class="align-self-center">-</span>
                <input
                  type="text"
                  v-model="formData.letra"
                  class="municipal-form-control"
                  placeholder="Letra"
                  maxlength="2"
                  style="flex: 1;"
                />
              </div>
            </div>

            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="user" class="me-1" />
                Concesionario:
                <span class="required">*</span>
              </label>
              <input
                type="text"
                v-model="formData.concesionario"
                class="municipal-form-control"
              />
            </div>
          </div>

          <div class="row g-3 mt-2">
            <div class="col-12">
              <label class="municipal-form-label">
                <font-awesome-icon icon="map-marker-alt" class="me-1" />
                Ubicación:
              </label>
              <input
                type="text"
                v-model="formData.ubicacion"
                class="municipal-form-control"
              />
            </div>
          </div>

          <div class="row g-3 mt-2">
            <div class="col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="ruler-combined" class="me-1" />
                Superficie:
                <span class="required">*</span>
              </label>
              <input
                type="number"
                v-model.number="formData.superficie"
                class="municipal-form-control"
                :min="0"
                step="0.01"
              />
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="file-alt" class="me-1" />
                Licencia:
                <span class="required">*</span>
              </label>
              <input
                type="number"
                v-model.number="formData.licencia"
                class="municipal-form-control"
                :min="0"
              />
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="tag" class="me-1" />
                Tipo Local:
                <span class="required">*</span>
              </label>
              <select
                v-model="formData.tipoLocal"
                class="municipal-form-control"
              >
                <option value="INTERNO">INTERNO</option>
                <option value="EXTERNO">EXTERNO</option>
              </select>
            </div>
          </div>

          <div class="row g-3 mt-2">
            <div class="col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="building" class="me-1" />
                Oficina:
              </label>
              <input
                type="number"
                v-model.number="formData.oficina"
                class="municipal-form-control"
                :min="0"
              />
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="building" class="me-1" />
                Sector:
              </label>
              <input
                type="text"
                v-model="formData.sector"
                class="municipal-form-control"
              />
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="map" class="me-1" />
                Zona:
              </label>
              <input
                type="number"
                v-model.number="formData.zona"
                class="municipal-form-control"
                :min="0"
              />
            </div>
          </div>

          <div class="row g-3 mt-2">
            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-alt" class="me-1" />
                Año Inicio:
                <span class="required">*</span>
              </label>
              <input
                type="number"
                v-model.number="formData.anioInicio"
                class="municipal-form-control"
                :min="2000"
                :max="2099"
              />
            </div>
            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar" class="me-1" />
                Mes Inicio:
                <span class="required">*</span>
              </label>
              <select
                v-model.number="formData.mesInicio"
                class="municipal-form-control"
              >
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">
                  {{ mes.label }}
                </option>
              </select>
            </div>
          </div>

          <div class="d-flex gap-2 mt-4">
            <button
              class="btn-municipal-primary"
              @click="handleGuardar"
              :disabled="isLoading"
            >
              <font-awesome-icon icon="check" />
              Crear Local
            </button>
            <button
              class="btn-municipal-secondary"
              @click="handleLimpiar"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal
      :show="showDocumentation"
      :componentName="'RNuevos'"
      :moduleName="'otras_obligaciones'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const router = useRouter()
const { execute } = useApi()
const { isLoading, startLoading, stopLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

const showDocumentation = ref(false)

const formData = reactive({
  numero: '',
  letra: '',
  concesionario: '',
  ubicacion: '',
  superficie: 0,
  licencia: 0,
  tipoLocal: 'INTERNO',
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

const handleGuardar = async () => {
  if (!formData.numero || !formData.concesionario || !formData.superficie || !formData.licencia) {
    showToast('warning', 'Complete los campos requeridos')
    return
  }

  startLoading('Creando local...')
  try {
    const control = `${formData.numero}-${formData.letra || ''}`
    const response = await execute(
      'sp_ins34_rastro_01',
      'otras_obligaciones',
      [
        { nombre: 'par_tabla', valor: 3, tipo: 'integer' },
        { nombre: 'par_control', valor: control, tipo: 'string' },
        { nombre: 'par_conces', valor: formData.concesionario, tipo: 'string' },
        { nombre: 'par_ubica', valor: formData.ubicacion, tipo: 'string' },
        { nombre: 'par_sup', valor: formData.superficie, tipo: 'numeric' },
        { nombre: 'par_axo_ini', valor: formData.anioInicio, tipo: 'integer' },
        { nombre: 'par_mes_ini', valor: formData.mesInicio, tipo: 'integer' },
        { nombre: 'par_ofna', valor: formData.oficina, tipo: 'integer' },
        { nombre: 'par_sector', valor: formData.sector, tipo: 'string' },
        { nombre: 'par_zona', valor: formData.zona, tipo: 'integer' },
        { nombre: 'par_lic', valor: formData.licencia, tipo: 'integer' },
        { nombre: 'par_descrip', valor: formData.tipoLocal, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.expression === 0) {
      showToast('success', 'Local creado exitosamente')
      handleLimpiar()
    } else {
      const mensaje = response?.result?.[0]?.expression_1 || 'Error al crear local'
      showToast('error', mensaje)
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    stopLoading()
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
    tipoLocal: 'INTERNO',
    oficina: 1,
    sector: '',
    zona: 1,
    anioInicio: new Date().getFullYear(),
    mesInicio: new Date().getMonth() + 1
  })
}

const openDocumentation = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

const goBack = () => {
  router.push('/otras_obligaciones')
}
</script>
