<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-line" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Actualizaciones</h1>
        <p>Otras Obligaciones - Actualización de datos de contratos</p>
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
      <!-- Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Búsqueda de Local</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Control:</label>
              <input type="text" v-model="formData.numero" class="municipal-form-control" placeholder="Número" maxlength="3" style="width: 120px; display: inline-block; margin-right: 10px;" />
              <span style="margin: 0 10px;">-</span>
              <input type="text" v-model="formData.letra" class="municipal-form-control" placeholder="Letra" maxlength="2" style="width: 100px; display: inline-block;" />
            </div>
            <div class="form-group">
              <button class="btn-municipal-primary" @click="handleBuscar" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del local encontrado -->
      <div class="municipal-card" v-if="datosLocal.control">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="info-circle" /> Datos del Local</h5>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <strong>Control:</strong>
              <span>{{ datosLocal.control }}</span>
            </div>
            <div class="info-item">
              <strong>Status:</strong>
              <span>{{ datosLocal.descrip_stat }}</span>
            </div>
            <div class="info-item">
              <strong>Concesionario:</strong>
              <span>{{ datosLocal.concesionario }}</span>
            </div>
            <div class="info-item">
              <strong>Ubicación:</strong>
              <span>{{ datosLocal.ubicacion }}</span>
            </div>
            <div class="info-item">
              <strong>Superficie:</strong>
              <span>{{ datosLocal.superficie }}</span>
            </div>
            <div class="info-item">
              <strong>Licencia:</strong>
              <span>{{ datosLocal.licencia }}</span>
            </div>
            <div class="info-item">
              <strong>Unidades:</strong>
              <span>{{ datosLocal.unidades }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Formulario de actualización -->
      <div class="municipal-card" v-if="datosLocal.control">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="edit" /> Tipo de Actualización</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-group">
            <label class="municipal-form-label">Seleccione qué desea actualizar:</label>
            <div class="radio-group">
              <label class="radio-label">
                <input type="radio" name="tipoAct" value="0" v-model="formData.tipoActualizacion" @change="handleTipoChange" />
                <span>Concesionario</span>
              </label>
              <label class="radio-label">
                <input type="radio" name="tipoAct" value="1" v-model="formData.tipoActualizacion" @change="handleTipoChange" />
                <span>Ubicación</span>
              </label>
              <label class="radio-label">
                <input type="radio" name="tipoAct" value="2" v-model="formData.tipoActualizacion" @change="handleTipoChange" />
                <span>Licencia</span>
              </label>
              <label class="radio-label">
                <input type="radio" name="tipoAct" value="3" v-model="formData.tipoActualizacion" @change="handleTipoChange" />
                <span>Superficie</span>
              </label>
              <label class="radio-label">
                <input type="radio" name="tipoAct" value="4" v-model="formData.tipoActualizacion" @change="handleTipoChange" />
                <span>Tipo de Local</span>
              </label>
              <label class="radio-label">
                <input type="radio" name="tipoAct" value="5" v-model="formData.tipoActualizacion" @change="handleTipoChange" />
                <span>Inicio de Obligación</span>
              </label>
            </div>
          </div>

          <!-- Campos de edición según tipo -->
          <div v-if="mostrarCampoEdicion" class="update-form">
            <!-- Concesionario -->
            <div v-if="formData.tipoActualizacion === '0'" class="form-group">
              <label class="municipal-form-label">Nuevo Concesionario:</label>
              <input type="text" v-model="formData.nuevoConcesionario" class="municipal-form-control" />
            </div>

            <!-- Ubicación -->
            <div v-if="formData.tipoActualizacion === '1'" class="form-group">
              <label class="municipal-form-label">Nueva Ubicación:</label>
              <input type="text" v-model="formData.nuevaUbicacion" class="municipal-form-control" />
            </div>

            <!-- Licencia -->
            <div v-if="formData.tipoActualizacion === '2'" class="form-group">
              <label class="municipal-form-label">Nueva Licencia:</label>
              <input type="number" v-model.number="formData.nuevaLicencia" class="municipal-form-control" :min="0" />
            </div>

            <!-- Superficie -->
            <div v-if="formData.tipoActualizacion === '3'" class="form-group">
              <label class="municipal-form-label">Nueva Superficie:</label>
              <input type="number" v-model.number="formData.nuevaSuperficie" class="municipal-form-control" :min="0" step="0.01" />
            </div>

            <!-- Tipo Local -->
            <div v-if="formData.tipoActualizacion === '4'" class="form-group">
              <label class="municipal-form-label">Tipo de Local:</label>
              <select v-model="formData.nuevoTipoLocal" class="municipal-form-control">
                <option value="INTERNO">INTERNO</option>
                <option value="EXTERNO">EXTERNO</option>
              </select>
            </div>

            <!-- Año y Mes para opciones 3, 4, 5 -->
            <div v-if="['3', '4', '5'].includes(formData.tipoActualizacion)" class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Año de Inicio:</label>
                <input type="number" v-model.number="formData.anioInicio" class="municipal-form-control" :min="2000" :max="2099" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Mes de Inicio:</label>
                <select v-model.number="formData.mesInicio" class="municipal-form-control">
                  <option v-for="mes in meses" :key="mes.value" :value="mes.value">{{ mes.label }}</option>
                </select>
              </div>
            </div>

            <!-- Botones -->
            <div class="form-row">
              <button class="btn-municipal-primary" @click="handleAplicar" :disabled="loading">
                <font-awesome-icon icon="check" /> Aplicar Cambios
              </button>
              <button class="btn-municipal-secondary" @click="handleCancelar" style="margin-left: 10px;">
                <font-awesome-icon icon="times" /> Cancelar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Procesando...</p>
        </div>
      </div>
    </div>

    <!-- Modal de documentación -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'RActualiza'"
      :moduleName="'otras_obligaciones'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const router = useRouter()
const { callApi } = useApi()
const { handleError, showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const datosLocal = ref({})
const mostrarCampoEdicion = ref(false)

const formData = reactive({
  numero: '',
  letra: '',
  tipoActualizacion: '',
  nuevoConcesionario: '',
  nuevaUbicacion: '',
  nuevaLicencia: 0,
  nuevaSuperficie: 0,
  nuevoTipoLocal: '',
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

const handleBuscar = async () => {
  if (!formData.numero) {
    showToast('warning', 'Debe ingresar el número de control')
    return
  }

  loading.value = true
  try {
    const control = `${formData.numero}-${formData.letra || ''}`
    const response = await callApi('SP_RACTUALIZA_BUSCAR', {
      p_control: control
    })

    if (response.data && response.data.length > 0) {
      datosLocal.value = response.data[0]
      formData.tipoActualizacion = ''
      mostrarCampoEdicion.value = false
      showToast('success', 'Local encontrado')
    } else {
      showToast('warning', 'No se encontró el local con ese control')
      datosLocal.value = {}
    }
  } catch (error) {
    handleError(error, 'Error al buscar local')
  } finally {
    loading.value = false
  }
}

const handleTipoChange = () => {
  mostrarCampoEdicion.value = true

  // Pre-cargar valores actuales
  if (formData.tipoActualizacion === '0') {
    formData.nuevoConcesionario = datosLocal.value.concesionario || ''
  } else if (formData.tipoActualizacion === '1') {
    formData.nuevaUbicacion = datosLocal.value.ubicacion || ''
  } else if (formData.tipoActualizacion === '2') {
    formData.nuevaLicencia = datosLocal.value.licencia || 0
  } else if (formData.tipoActualizacion === '3') {
    formData.nuevaSuperficie = datosLocal.value.superficie || 0
  } else if (formData.tipoActualizacion === '4') {
    formData.nuevoTipoLocal = datosLocal.value.unidades || 'INTERNO'
  }
}

const handleAplicar = async () => {
  // Validar que el nuevo valor sea diferente
  let valorNuevo, valorActual

  switch (formData.tipoActualizacion) {
    case '0':
      valorNuevo = formData.nuevoConcesionario
      valorActual = datosLocal.value.concesionario
      break
    case '1':
      valorNuevo = formData.nuevaUbicacion
      valorActual = datosLocal.value.ubicacion
      break
    case '2':
      valorNuevo = formData.nuevaLicencia
      valorActual = datosLocal.value.licencia
      break
    case '3':
      valorNuevo = formData.nuevaSuperficie
      valorActual = datosLocal.value.superficie
      break
    case '4':
      valorNuevo = formData.nuevoTipoLocal
      valorActual = datosLocal.value.unidades
      break
  }

  if (valorNuevo === valorActual) {
    showToast('warning', 'El nuevo valor debe ser diferente al actual')
    return
  }

  // Verificar pagos si es necesario (opciones 3, 4, 5)
  if (['3', '4', '5'].includes(formData.tipoActualizacion)) {
    const periodo = `${formData.anioInicio}-${String(formData.mesInicio).padStart(2, '0')}`
    const pagosResponse = await callApi('SP_RACTUALIZA_VERIFICAR_PAGOS', {
      p_id_datos: datosLocal.value.id_34_datos,
      p_periodo: periodo
    })

    if (pagosResponse.data && pagosResponse.data[0].total_pagos > 0) {
      showToast('warning', 'Existe(n) pago(s) realizado(s) a partir de este periodo')
      return
    }
  }

  const result = await Swal.fire({
    title: 'Confirmación',
    text: '¿Está seguro de aplicar estos cambios?',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí',
    cancelButtonText: 'No',
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  })

  if (result.isConfirmed) {
    loading.value = true
    try {
      const response = await callApi('SP_RACTUALIZA_ACTUALIZAR', {
        par_Opc: parseInt(formData.tipoActualizacion),
        par_Id_34_datos: datosLocal.value.id_34_datos,
        par_Conces: formData.nuevoConcesionario || '',
        par_Ubica: formData.nuevaUbicacion || '',
        par_Lic: formData.nuevaLicencia || 0,
        par_Sup: formData.nuevaSuperficie || 0,
        par_Descrip: formData.nuevoTipoLocal || '',
        par_Aso_Ini: formData.anioInicio,
        par_Mes_Ini: formData.mesInicio
      })

      showToast('success', 'Actualización realizada correctamente')
      handleCancelar()
    } catch (error) {
      handleError(error, 'Error al actualizar')
    } finally {
      loading.value = false
    }
  }
}

const handleCancelar = () => {
  datosLocal.value = {}
  formData.numero = ''
  formData.letra = ''
  formData.tipoActualizacion = ''
  mostrarCampoEdicion.value = false
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
