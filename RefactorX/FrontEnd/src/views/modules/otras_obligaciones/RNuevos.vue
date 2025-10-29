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
      <button class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" /> Salir
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
              <label class="municipal-form-label">Control: <span class="required">*</span></label>
              <input type="text" v-model="formData.numero" class="municipal-form-control" placeholder="Número" maxlength="3" style="width: 120px; display: inline-block; margin-right: 10px;" />
              <span style="margin: 0 10px;">-</span>
              <input type="text" v-model="formData.letra" class="municipal-form-control" placeholder="Letra" maxlength="2" style="width: 100px; display: inline-block;" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Concesionario: <span class="required">*</span></label>
              <input type="text" v-model="formData.concesionario" class="municipal-form-control" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Ubicación:</label>
              <input type="text" v-model="formData.ubicacion" class="municipal-form-control" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Superficie: <span class="required">*</span></label>
              <input type="number" v-model.number="formData.superficie" class="municipal-form-control" :min="0" step="0.01" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Licencia: <span class="required">*</span></label>
              <input type="number" v-model.number="formData.licencia" class="municipal-form-control" :min="0" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo Local: <span class="required">*</span></label>
              <select v-model="formData.tipoLocal" class="municipal-form-control">
                <option value="INTERNO">INTERNO</option>
                <option value="EXTERNO">EXTERNO</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina:</label>
              <input type="number" v-model.number="formData.oficina" class="municipal-form-control" :min="0" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sector:</label>
              <input type="text" v-model="formData.sector" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Zona:</label>
              <input type="number" v-model.number="formData.zona" class="municipal-form-control" :min="0" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año Inicio: <span class="required">*</span></label>
              <input type="number" v-model.number="formData.anioInicio" class="municipal-form-control" :min="2000" :max="2099" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mes Inicio: <span class="required">*</span></label>
              <select v-model.number="formData.mesInicio" class="municipal-form-control">
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">{{ mes.label }}</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <button class="btn-municipal-primary" @click="handleGuardar" :disabled="loading">
              <font-awesome-icon icon="check" /> Crear Local
            </button>
            <button class="btn-municipal-secondary" @click="handleLimpiar" style="margin-left: 10px;">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
      </div>

      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Creando local...</p>
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
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const router = useRouter()
const { callApi } = useApi()
const { handleError, showToast } = useLicenciasErrorHandler()

const loading = ref(false)
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

  loading.value = true
  try {
    const control = `${formData.numero}-${formData.letra || ''}`
    await callApi('SP_RNUEVOS_INSERTAR', {
      par_tabla: '3',
      par_control: control,
      par_conces: formData.concesionario,
      par_ubica: formData.ubicacion,
      par_sup: formData.superficie,
      par_Axo_Ini: formData.anioInicio,
      par_Mes_Ini: formData.mesInicio,
      par_ofna: formData.oficina,
      par_sector: formData.sector,
      par_zona: formData.zona,
      par_lic: formData.licencia,
      par_Descrip: formData.tipoLocal
    })

    showToast('success', 'Local creado exitosamente')
    handleLimpiar()
  } catch (error) {
    handleError(error, 'Error al crear local')
  } finally {
    loading.value = false
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
