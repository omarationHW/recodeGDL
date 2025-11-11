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
      <!-- Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row g-3 align-items-end">
            <div class="col-md-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="hashtag" class="me-1" />
                Número de Control:
              </label>
              <input
                type="text"
                v-model="formData.numero"
                class="municipal-form-control"
                placeholder="Número"
                maxlength="3"
              />
            </div>
            <div class="col-md-2">
              <label class="municipal-form-label">
                <font-awesome-icon icon="font" class="me-1" />
                Letra:
              </label>
              <input
                type="text"
                v-model="formData.letra"
                class="municipal-form-control"
                placeholder="Letra"
                maxlength="2"
              />
            </div>
            <div class="col-md-3">
              <button
                class="btn-municipal-primary w-100"
                @click="handleBuscar"
                :disabled="isLoading"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del local encontrado -->
      <div class="municipal-card" v-if="datosLocal.control">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Datos del Local
          </h5>
          <span class="badge badge-purple">{{ datosLocal.control }}</span>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <label>
                <font-awesome-icon icon="hashtag" class="me-1" />
                Control:
              </label>
              <span>{{ datosLocal.control }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="flag" class="me-1" />
                Status:
              </label>
              <span>{{ datosLocal.status }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="user" class="me-1" />
                Concesionario:
              </label>
              <span>{{ datosLocal.concesionario }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="map-marker-alt" class="me-1" />
                Ubicación:
              </label>
              <span>{{ datosLocal.ubicacion }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="ruler-combined" class="me-1" />
                Superficie:
              </label>
              <span>{{ datosLocal.superficie }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="file-alt" class="me-1" />
                Licencia:
              </label>
              <span>{{ datosLocal.licencia }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="tag" class="me-1" />
                Unidades:
              </label>
              <span>{{ datosLocal.unidades }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Formulario de actualización -->
      <div class="municipal-card" v-if="datosLocal.control">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Tipo de Actualización
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="mb-3">
            <label class="municipal-form-label">
              <font-awesome-icon icon="tasks" class="me-1" />
              Seleccione qué desea actualizar:
            </label>
            <div class="d-flex flex-column gap-2">
              <label class="form-check-label">
                <input
                  type="radio"
                  name="tipoAct"
                  value="0"
                  v-model="formData.tipoActualizacion"
                  @change="handleTipoChange"
                  class="form-check-input me-2"
                />
                <font-awesome-icon icon="user" class="me-1" />
                <span>Concesionario</span>
              </label>
              <label class="form-check-label">
                <input
                  type="radio"
                  name="tipoAct"
                  value="1"
                  v-model="formData.tipoActualizacion"
                  @change="handleTipoChange"
                  class="form-check-input me-2"
                />
                <font-awesome-icon icon="map-marker-alt" class="me-1" />
                <span>Ubicación</span>
              </label>
              <label class="form-check-label">
                <input
                  type="radio"
                  name="tipoAct"
                  value="2"
                  v-model="formData.tipoActualizacion"
                  @change="handleTipoChange"
                  class="form-check-input me-2"
                />
                <font-awesome-icon icon="file-alt" class="me-1" />
                <span>Licencia</span>
              </label>
              <label class="form-check-label">
                <input
                  type="radio"
                  name="tipoAct"
                  value="3"
                  v-model="formData.tipoActualizacion"
                  @change="handleTipoChange"
                  class="form-check-input me-2"
                />
                <font-awesome-icon icon="ruler-combined" class="me-1" />
                <span>Superficie</span>
              </label>
              <label class="form-check-label">
                <input
                  type="radio"
                  name="tipoAct"
                  value="4"
                  v-model="formData.tipoActualizacion"
                  @change="handleTipoChange"
                  class="form-check-input me-2"
                />
                <font-awesome-icon icon="tag" class="me-1" />
                <span>Tipo de Local</span>
              </label>
              <label class="form-check-label">
                <input
                  type="radio"
                  name="tipoAct"
                  value="5"
                  v-model="formData.tipoActualizacion"
                  @change="handleTipoChange"
                  class="form-check-input me-2"
                />
                <font-awesome-icon icon="calendar-alt" class="me-1" />
                <span>Inicio de Obligación</span>
              </label>
            </div>
          </div>

          <!-- Campos de edición según tipo -->
          <div v-if="mostrarCampoEdicion" class="mt-4">
            <!-- Concesionario -->
            <div v-if="formData.tipoActualizacion === '0'" class="mb-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="user" class="me-1" />
                Nuevo Concesionario:
              </label>
              <input
                type="text"
                v-model="formData.nuevoConcesionario"
                class="municipal-form-control"
              />
            </div>

            <!-- Ubicación -->
            <div v-if="formData.tipoActualizacion === '1'" class="mb-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="map-marker-alt" class="me-1" />
                Nueva Ubicación:
              </label>
              <input
                type="text"
                v-model="formData.nuevaUbicacion"
                class="municipal-form-control"
              />
            </div>

            <!-- Licencia -->
            <div v-if="formData.tipoActualizacion === '2'" class="mb-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="file-alt" class="me-1" />
                Nueva Licencia:
              </label>
              <input
                type="number"
                v-model.number="formData.nuevaLicencia"
                class="municipal-form-control"
                :min="0"
              />
            </div>

            <!-- Superficie -->
            <div v-if="formData.tipoActualizacion === '3'" class="mb-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="ruler-combined" class="me-1" />
                Nueva Superficie:
              </label>
              <input
                type="number"
                v-model.number="formData.nuevaSuperficie"
                class="municipal-form-control"
                :min="0"
                step="0.01"
              />
            </div>

            <!-- Tipo Local -->
            <div v-if="formData.tipoActualizacion === '4'" class="mb-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="tag" class="me-1" />
                Tipo de Local:
              </label>
              <select v-model="formData.nuevoTipoLocal" class="municipal-form-control">
                <option value="INTERNO">INTERNO</option>
                <option value="EXTERNO">EXTERNO</option>
              </select>
            </div>

            <!-- Año y Mes para opciones 3, 4, 5 -->
            <div v-if="['3', '4', '5'].includes(formData.tipoActualizacion)" class="row g-3">
              <div class="col-md-6">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="calendar-alt" class="me-1" />
                  Año de Inicio:
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
                  Mes de Inicio:
                </label>
                <select v-model.number="formData.mesInicio" class="municipal-form-control">
                  <option v-for="mes in meses" :key="mes.value" :value="mes.value">
                    {{ mes.label }}
                  </option>
                </select>
              </div>
            </div>

            <!-- Botones -->
            <div class="d-flex gap-2 mt-4">
              <button
                class="btn-municipal-primary"
                @click="handleAplicar"
                :disabled="isLoading"
              >
                <font-awesome-icon icon="check" />
                Aplicar Cambios
              </button>
              <button
                class="btn-municipal-secondary"
                @click="handleCancelar"
              >
                <font-awesome-icon icon="times" />
                Cancelar
              </button>
            </div>
          </div>
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
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const router = useRouter()
const { execute } = useApi()
const { isLoading, startLoading, stopLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

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

  startLoading('Buscando local...')
  try {
    const control = `${formData.numero}-${formData.letra || ''}`
    const response = await execute(
      'buscar_concesion',
      'otras_obligaciones',
      [
        { nombre: 'control', valor: control, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      datosLocal.value = response.result[0]
      formData.tipoActualizacion = ''
      mostrarCampoEdicion.value = false
      showToast('success', 'Local encontrado')
    } else {
      showToast('warning', 'No se encontró el local con ese control')
      datosLocal.value = {}
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    stopLoading()
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
    try {
      const periodo = `${formData.anioInicio}-${String(formData.mesInicio).padStart(2, '0')}`
      const pagosResponse = await execute(
        'verificar_pagos',
        'otras_obligaciones',
        [
          { nombre: 'id_datos', valor: datosLocal.value.id_34_datos, tipo: 'integer' },
          { nombre: 'periodo', valor: periodo, tipo: 'string' }
        ],
        'guadalajara'
      )

      if (pagosResponse && pagosResponse.result && pagosResponse.result.length > 0) {
        showToast('warning', 'Existe(n) pago(s) realizado(s) a partir de este periodo')
        return
      }
    } catch (error) {
      console.warn('Error al verificar pagos:', error)
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
    startLoading('Aplicando cambios...')
    try {
      const response = await execute(
        'actualizar_concesion',
        'otras_obligaciones',
        [
          { nombre: 'opc', valor: parseInt(formData.tipoActualizacion), tipo: 'integer' },
          { nombre: 'id_34_datos', valor: datosLocal.value.id_34_datos, tipo: 'integer' },
          { nombre: 'concesionario', valor: formData.nuevoConcesionario || '', tipo: 'string' },
          { nombre: 'ubicacion', valor: formData.nuevaUbicacion || '', tipo: 'string' },
          { nombre: 'licencia', valor: formData.nuevaLicencia || 0, tipo: 'integer' },
          { nombre: 'superficie', valor: formData.nuevaSuperficie || 0, tipo: 'numeric' },
          { nombre: 'descrip', valor: formData.nuevoTipoLocal || '', tipo: 'string' },
          { nombre: 'aso_ini', valor: formData.anioInicio, tipo: 'integer' },
          { nombre: 'mes_ini', valor: formData.mesInicio, tipo: 'integer' }
        ],
        'guadalajara'
      )

      if (response && response.result && response.result[0]?.resultado === 0) {
        showToast('success', 'Actualización realizada correctamente')
        handleCancelar()
      } else {
        const mensaje = response?.result?.[0]?.mensaje || 'Error al actualizar'
        showToast('error', mensaje)
      }
    } catch (error) {
      handleApiError(error)
    } finally {
      stopLoading()
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
