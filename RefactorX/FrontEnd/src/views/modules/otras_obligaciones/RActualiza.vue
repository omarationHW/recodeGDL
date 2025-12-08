<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="edit" />
      </div>
      <div class="module-view-info">
        <h1>Actualización de Datos de Locales</h1>
        <p>Otras Obligaciones - Rastro</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-secondary"
          @click="goBack"
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
            Buscar Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row g-3 align-items-end">
            <div class="col-md-3">
              <label class="municipal-form-label">Número de Local</label>
              <input
                type="text"
                v-model="busqueda.numero"
                class="municipal-form-control"
                maxlength="3"
                @keyup.enter="focusLetra"
                placeholder="Número"
              />
            </div>
            <div class="col-md-2">
              <label class="municipal-form-label">Letra</label>
              <input
                type="text"
                v-model="busqueda.letra"
                ref="letraInput"
                class="municipal-form-control"
                maxlength="1"
                @keyup.enter="buscarLocal"
                placeholder="Letra"
              />
            </div>
            <div class="col-md-3">
              <button
                class="btn-municipal-primary"
                @click="buscarLocal"
                :disabled="loading"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del Local -->
      <div class="municipal-card" v-if="concesion">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Datos del Local
          </h5>
          <button
            class="btn-municipal-success"
            @click="imprimirDatos"
          >
            <font-awesome-icon icon="print" />
            Imprimir
          </button>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-6">
              <div class="info-item">
                <strong>Concesionario:</strong>
                <span>{{ concesion.concesionario }}</span>
              </div>
            </div>
            <div class="col-md-6">
              <div class="info-item">
                <strong>Ubicación:</strong>
                <span>{{ concesion.ubicacion }}</span>
              </div>
            </div>
            <div class="col-md-4">
              <div class="info-item">
                <strong>Superficie:</strong>
                <span>{{ concesion.superficie }} m²</span>
              </div>
            </div>
            <div class="col-md-4">
              <div class="info-item">
                <strong>Licencia:</strong>
                <span>{{ concesion.licencia }}</span>
              </div>
            </div>
            <div class="col-md-4">
              <div class="info-item">
                <strong>Tipo de Local:</strong>
                <span>{{ concesion.unidades }}</span>
              </div>
            </div>
            <div class="col-md-4">
              <div class="info-item">
                <strong>Inicio Obligación:</strong>
                <span>{{ formatDate(concesion.fecha_inicio) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Opciones de Actualización -->
      <div class="municipal-card" v-if="concesion">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="cogs" />
            Opciones de Actualización
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row g-3 mb-3">
            <div class="col-md-6">
              <label class="municipal-form-label">Seleccione qué desea actualizar:</label>
              <select v-model="opcionSeleccionada" class="municipal-form-control" @change="cambiarOpcion">
                <option :value="0">Concesionario</option>
                <option :value="1">Ubicación</option>
                <option :value="2">Licencia</option>
                <option :value="3">Superficie</option>
                <option :value="4">Tipo de Local</option>
                <option :value="5">Inicio de Obligación</option>
              </select>
            </div>
          </div>

          <!-- Opción 0: Concesionario -->
          <div v-if="opcionSeleccionada === 0" class="update-form">
            <div class="row g-3">
              <div class="col-md-8">
                <label class="municipal-form-label">Nuevo Concesionario</label>
                <input
                  type="text"
                  v-model="formData.concesionario"
                  class="municipal-form-control"
                  maxlength="100"
                />
              </div>
            </div>
          </div>

          <!-- Opción 1: Ubicación -->
          <div v-if="opcionSeleccionada === 1" class="update-form">
            <div class="row g-3">
              <div class="col-md-8">
                <label class="municipal-form-label">Nueva Ubicación</label>
                <input
                  type="text"
                  v-model="formData.ubicacion"
                  class="municipal-form-control"
                  maxlength="255"
                />
              </div>
            </div>
          </div>

          <!-- Opción 2: Licencia -->
          <div v-if="opcionSeleccionada === 2" class="update-form">
            <div class="row g-3">
              <div class="col-md-4">
                <label class="municipal-form-label">Nueva Licencia</label>
                <input
                  type="number"
                  v-model.number="formData.licencia"
                  class="municipal-form-control"
                />
              </div>
            </div>
          </div>

          <!-- Opción 3: Superficie -->
          <div v-if="opcionSeleccionada === 3" class="update-form">
            <div class="row g-3">
              <div class="col-md-3">
                <label class="municipal-form-label">Nueva Superficie (m²)</label>
                <input
                  type="number"
                  step="0.01"
                  v-model.number="formData.superficie"
                  class="municipal-form-control"
                />
              </div>
              <div class="col-md-3">
                <label class="municipal-form-label">Año de Inicio</label>
                <input
                  type="number"
                  v-model.number="formData.aso_ini"
                  class="municipal-form-control"
                  maxlength="4"
                />
              </div>
              <div class="col-md-3">
                <label class="municipal-form-label">Mes de Inicio</label>
                <select v-model.number="formData.mes_ini" class="municipal-form-control">
                  <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Opción 4: Tipo de Local -->
          <div v-if="opcionSeleccionada === 4" class="update-form">
            <div class="row g-3">
              <div class="col-md-3">
                <label class="municipal-form-label">Nuevo Tipo de Local</label>
                <select v-model="formData.descrip" class="municipal-form-control">
                  <option value="INTERNO">INTERNO</option>
                  <option value="EXTERNO">EXTERNO</option>
                </select>
              </div>
              <div class="col-md-3">
                <label class="municipal-form-label">Año de Inicio</label>
                <input
                  type="number"
                  v-model.number="formData.aso_ini"
                  class="municipal-form-control"
                  maxlength="4"
                />
              </div>
              <div class="col-md-3">
                <label class="municipal-form-label">Mes de Inicio</label>
                <select v-model.number="formData.mes_ini" class="municipal-form-control">
                  <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Opción 5: Inicio de Obligación -->
          <div v-if="opcionSeleccionada === 5" class="update-form">
            <div class="row g-3">
              <div class="col-md-3">
                <label class="municipal-form-label">Año de Inicio</label>
                <input
                  type="number"
                  v-model.number="formData.aso_ini"
                  class="municipal-form-control"
                  maxlength="4"
                />
              </div>
              <div class="col-md-3">
                <label class="municipal-form-label">Mes de Inicio</label>
                <select v-model.number="formData.mes_ini" class="municipal-form-control">
                  <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
                </select>
              </div>
            </div>
          </div>

          <div class="row g-3 mt-3">
            <div class="col-md-12">
              <button
                class="btn-municipal-success"
                @click="aplicarCambio"
                :disabled="saving"
              >
                <font-awesome-icon icon="check" />
                {{ saving ? 'Guardando...' : 'Aplicar Cambio' }}
              </button>
              <button
                class="btn-municipal-secondary ms-2"
                @click="reset"
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
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { usePdfExport } from '@/composables/usePdfExport'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const BASE_DB = 'otras_obligaciones'
const router = useRouter()
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { exportToPdf } = usePdfExport()

const showDocumentation = ref(false)
const loading = ref(false)
const saving = ref(false)
const concesion = ref(null)
const letraInput = ref(null)
const opcionSeleccionada = ref(0)

const busqueda = ref({
  numero: '',
  letra: ''
})

const formData = ref({
  concesionario: '',
  ubicacion: '',
  licencia: 0,
  superficie: 0,
  descrip: 'INTERNO',
  aso_ini: new Date().getFullYear(),
  mes_ini: 1
})

const meses = [
  { value: 1, label: '01 - Enero' },
  { value: 2, label: '02 - Febrero' },
  { value: 3, label: '03 - Marzo' },
  { value: 4, label: '04 - Abril' },
  { value: 5, label: '05 - Mayo' },
  { value: 6, label: '06 - Junio' },
  { value: 7, label: '07 - Julio' },
  { value: 8, label: '08 - Agosto' },
  { value: 9, label: '09 - Septiembre' },
  { value: 10, label: '10 - Octubre' },
  { value: 11, label: '11 - Noviembre' },
  { value: 12, label: '12 - Diciembre' }
]

const formatDate = (dateString) => {
  if (!dateString) return '-'
  const date = new Date(dateString)
  return date.toLocaleDateString('es-MX')
}

const focusLetra = () => {
  if (letraInput.value) {
    letraInput.value.focus()
  }
}

const cambiarOpcion = () => {
  if (concesion.value) {
    formData.value.concesionario = concesion.value.concesionario || ''
    formData.value.ubicacion = concesion.value.ubicacion || ''
    formData.value.licencia = concesion.value.licencia || 0
    formData.value.superficie = concesion.value.superficie || 0
    formData.value.descrip = concesion.value.unidades || 'INTERNO'

    if (concesion.value.fecha_inicio) {
      const fecha = new Date(concesion.value.fecha_inicio)
      formData.value.aso_ini = fecha.getFullYear()
      formData.value.mes_ini = fecha.getMonth() + 1
    }
  }
}

const buscarLocal = async () => {
  if (!busqueda.value.numero) {
    showToast('warning', 'Ingrese el número de local')
    return
  }

  const control = busqueda.value.numero + (busqueda.value.letra ? '-' + busqueda.value.letra : '')

  loading.value = true
  showLoading('Buscando local...')

  try {
    const response = await execute(
      'buscar_concesion',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: 3, tipo: 'integer' },
        { nombre: 'par_control', valor: control, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const data = response.result[0]
      if (data.id_34_datos) {
        concesion.value = data
        cambiarOpcion()
        showToast('success', 'Local encontrado')
      } else {
        concesion.value = null
        showToast('warning', 'No existe LOCAL con este dato, intentalo de nuevo')
      }
    } else {
      concesion.value = null
      showToast('warning', 'No existe LOCAL con este dato, intentalo de nuevo')
    }
  } catch (error) {
    handleApiError(error)
    concesion.value = null
  } finally {
    loading.value = false
    hideLoading()
  }
}

const aplicarCambio = async () => {
  if (!concesion.value) {
    showToast('error', 'Debe buscar un local primero')
    return
  }

  // Validaciones
  if (opcionSeleccionada.value === 0 && !formData.value.concesionario) {
    showToast('warning', 'Debe ingresar el nuevo concesionario')
    return
  }
  if (opcionSeleccionada.value === 1 && !formData.value.ubicacion) {
    showToast('warning', 'Debe ingresar la nueva ubicación')
    return
  }
  if (opcionSeleccionada.value === 2 && !formData.value.licencia) {
    showToast('warning', 'Debe ingresar la nueva licencia')
    return
  }
  if ([3, 4, 5].includes(opcionSeleccionada.value) && (!formData.value.aso_ini || !formData.value.mes_ini)) {
    showToast('warning', 'Debe indicar año y mes de inicio')
    return
  }

  // Confirmación
  const opciones = ['Concesionario', 'Ubicación', 'Licencia', 'Superficie', 'Tipo de Local', 'Inicio de Obligación']
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    text: `Se actualizará: ${opciones[opcionSeleccionada.value]}`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  // Verificar pagos si es necesario (opciones 3, 4, 5)
  if ([3, 4, 5].includes(opcionSeleccionada.value)) {
    try {
      const pagosResponse = await execute(
        'verificar_pagos',
        BASE_DB,
        [{ nombre: 'p_id_34_datos', valor: concesion.value.id_34_datos, tipo: 'integer' }],
        'guadalajara'
      )

      if (pagosResponse && pagosResponse.result && pagosResponse.result[0] === true) {
        showToast('error', 'Existe pago(s) realizado(s) a partir de este periodo, intenta con otro')
        return
      }
    } catch (error) {
      // Si falla verificar_pagos, continuamos
      console.warn('Error verificando pagos:', error)
    }
  }

  saving.value = true
  showLoading('Aplicando cambio...')

  try {
    const response = await execute(
      'actualizar_concesion',
      BASE_DB,
      [
        { nombre: 'opc', valor: opcionSeleccionada.value, tipo: 'integer' },
        { nombre: 'id_34_datos', valor: concesion.value.id_34_datos, tipo: 'integer' },
        { nombre: 'concesionario', valor: formData.value.concesionario || '', tipo: 'string' },
        { nombre: 'ubicacion', valor: formData.value.ubicacion || '', tipo: 'string' },
        { nombre: 'licencia', valor: formData.value.licencia || 0, tipo: 'integer' },
        { nombre: 'superficie', valor: formData.value.superficie || 0, tipo: 'decimal' },
        { nombre: 'descrip', valor: formData.value.descrip || '', tipo: 'string' },
        { nombre: 'aso_ini', valor: formData.value.aso_ini || 0, tipo: 'integer' },
        { nombre: 'mes_ini', valor: formData.value.mes_ini || 0, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const data = response.result[0]
      saving.value = false
      hideLoading()

      if (data.resultado === 0) {
        await Swal.fire({
          icon: 'success',
          title: 'Actualizado',
          text: data.mensaje || 'Se ejecuto correctamente la actualizacion',
          confirmButtonColor: '#ea8215'
        })
        reset()
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: data.mensaje || 'Error en la actualizacion',
          confirmButtonColor: '#ea8215'
        })
      }
    } else {
      saving.value = false
      hideLoading()
      showToast('warning', 'Sin respuesta del servidor')
    }
  } catch (error) {
    saving.value = false
    hideLoading()
    handleApiError(error)
  }
}

const reset = () => {
  busqueda.value = { numero: '', letra: '' }
  concesion.value = null
  opcionSeleccionada.value = 0
  formData.value = {
    concesionario: '',
    ubicacion: '',
    licencia: 0,
    superficie: 0,
    descrip: 'INTERNO',
    aso_ini: new Date().getFullYear(),
    mes_ini: 1
  }
}

const imprimirDatos = () => {
  if (!concesion.value) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }

  const columns = [
    { header: 'Control', key: 'control', type: 'string' },
    { header: 'Concesionario', key: 'concesionario', type: 'string' },
    { header: 'Ubicacion', key: 'ubicacion', type: 'string' },
    { header: 'Superficie', key: 'superficie', type: 'number' },
    { header: 'Licencia', key: 'licencia', type: 'number' },
    { header: 'Tipo Local', key: 'unidades', type: 'string' },
    { header: 'Fecha Inicio', key: 'fecha_inicio', type: 'date' }
  ]

  const options = {
    title: 'Datos del Local',
    subtitle: `Control: ${concesion.value.control || ''}`,
    orientation: 'landscape'
  }

  exportToPdf([concesion.value], columns, options)
}

const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const goBack = () => router.push('/otras-obligaciones/menu')
</script>

<style scoped>
/* Estilos en municipal-theme.css */
</style>
