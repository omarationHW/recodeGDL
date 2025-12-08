<template>
  <div class="module-view">
    <!-- Header -->
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-days" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Ejercicios Fiscales</h1>
        <p>Aseo Contratado - Administración de ejercicios fiscales y periodos de facturación</p>
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
    
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <!-- Tabs -->
    <div class="municipal-tabs">
      <button
        class="municipal-tab"
        :class="{ active: tabActual === 'ejercicios' }"
        @click="tabActual = 'ejercicios'"
      >
        <font-awesome-icon icon="calendar" />
        Ejercicios
      </button>
      <button
        class="municipal-tab"
        :class="{ active: tabActual === 'periodos' }"
        @click="tabActual = 'periodos'"
      >
        <font-awesome-icon icon="calendar-week" />
        Periodos
      </button>
      <button
        class="municipal-tab"
        :class="{ active: tabActual === 'tarifas' }"
        @click="tabActual = 'tarifas'"
      >
        <font-awesome-icon icon="money-bill-wave" />
        Tarifas por Ejercicio
      </button>
    </div>

    <!-- Tab: Ejercicios Fiscales -->
    <div v-if="tabActual === 'ejercicios'">
      <div class="row">
        <!-- Lista de Ejercicios -->
        <div class="col-md-4">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Ejercicios Fiscales</h5>
            </div>
<div class="municipal-card-body">
              <div v-if="ejercicios.length > 0" style="max-height: 500px; overflow-y: auto;">
                <div
                  v-for="ejercicio in ejercicios"
                  :key="ejercicio.ejercicio"
                  class="ejercicio-item p-3 mb-2 border rounded"
                  :class="{
                    'border-primary bg-light': ejercicioSeleccionado?.ejercicio === ejercicio.ejercicio,
                    'border-success': ejercicio.activo && ejercicio.ejercicio === ejercicioActual
                  }"
                  @click="seleccionarEjercicio(ejercicio)"
                  style="cursor: pointer;"
                >
                  <div class="d-flex justify-content-between align-items-center">
                    <div>
                      <h5 class="mb-1">{{ ejercicio.ejercicio }}</h5>
                      <p class="mb-1 text-muted small">
                        {{ formatFecha(ejercicio.fecha_inicio) }} - {{ formatFecha(ejercicio.fecha_fin) }}
                      </p>
                      <div class="mt-2">
                        <span class="badge" :class="ejercicio.activo ? 'bg-success' : 'bg-secondary'">
                          {{ ejercicio.activo ? 'Activo' : 'Inactivo' }}
                        </span>
                        <span v-if="ejercicio.ejercicio === ejercicioActual" class="badge bg-primary ms-1">
                          Actual
                        </span>
                      </div>
                    </div>
                    <div class="text-end">
                      <small class="text-muted">{{ ejercicio.num_periodos || 12 }} periodos</small>
                    </div>
                  </div>
                </div>
              </div>
              <div v-else class="alert alert-info mb-0">
                <font-awesome-icon icon="info-circle" class="me-2" />
                No hay ejercicios registrados
              </div>

              <button class="btn-municipal-primary w-100 mt-3" @click="nuevoEjercicio">
                <font-awesome-icon icon="plus" class="me-1" />
                Nuevo Ejercicio
              </button>
            </div>
          </div>
        </div>

        <!-- Formulario de Ejercicio -->
        <div class="col-md-8">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>
                {{ modoEdicion ? `Ejercicio ${formEjercicio.ejercicio}` : 'Nuevo Ejercicio' }}
              </h5>
            </div>
            <div class="municipal-card-body">
              <div class="row">
                <div class="col-md-4">
                  <div class="form-group">
                    <label class="municipal-form-label">Año del Ejercicio <span class="text-danger">*</span></label>
                    <input
                      type="number"
                      class="municipal-form-control"
                      v-model.number="formEjercicio.ejercicio"
                      :disabled="modoEdicion"
                      min="2020"
                      max="2099"
                      placeholder="2024"
                    />
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label class="municipal-form-label">Número de Periodos <span class="text-danger">*</span></label>
                    <select class="municipal-form-control" v-model.number="formEjercicio.num_periodos">
                      <option value="12">12 (Mensual)</option>
                      <option value="24">24 (Quincenal)</option>
                      <option value="52">52 (Semanal)</option>
                      <option value="4">4 (Trimestral)</option>
                      <option value="6">6 (Bimestral)</option>
                    </select>
                  </div>
                </div>
              </div>

              <div class="row">
                <div class="col-md-6">
                  <div class="form-group">
                    <label class="municipal-form-label">Fecha de Inicio <span class="text-danger">*</span></label>
                    <input
                      type="date"
                      class="municipal-form-control"
                      v-model="formEjercicio.fecha_inicio"
                    />
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label class="municipal-form-label">Fecha de Fin <span class="text-danger">*</span></label>
                    <input
                      type="date"
                      class="municipal-form-control"
                      v-model="formEjercicio.fecha_fin"
                      :min="formEjercicio.fecha_inicio"
                    />
                  </div>
                </div>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Descripción</label>
                <textarea
                  class="municipal-form-control"
                  v-model="formEjercicio.descripcion"
                  rows="2"
                  placeholder="Descripción del ejercicio fiscal..."
                ></textarea>
              </div>

              <div class="row">
                <div class="col-md-6">
                  <div class="form-check mb-3">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="formEjercicio.activo"
                      id="ejercicioActivo"
                    />
                    <label class="form-check-label" for="ejercicioActivo">
                      Ejercicio activo
                    </label>
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-check mb-3">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="formEjercicio.generar_periodos_auto"
                      id="generarPeriodosAuto"
                      :disabled="modoEdicion"
                    />
                    <label class="form-check-label" for="generarPeriodosAuto">
                      Generar periodos automáticamente
                    </label>
                  </div>
                </div>
              </div>

              <div class="municipal-alert municipal-alert-info" v-if="formEjercicio.generar_periodos_auto && !modoEdicion">
                <font-awesome-icon icon="info-circle" class="me-2" />
                Se generarán {{ formEjercicio.num_periodos }} periodos automáticamente desde
                {{ formatFecha(formEjercicio.fecha_inicio) }} hasta {{ formatFecha(formEjercicio.fecha_fin) }}
              </div>

              <!-- Estadísticas del Ejercicio (solo en modo edición) -->
              <div v-if="modoEdicion && ejercicioSeleccionado" class="stats-dashboard mb-3">
                <div class="stat-item stat-primary">
                  <div class="stat-icon-mini">
                    <font-awesome-icon icon="file-contract" />
                  </div>
                  <div class="stat-details">
                    <div class="stat-value-mini">{{ ejercicioSeleccionado.total_contratos || 0 }}</div>
                    <div class="stat-label-mini">Contratos</div>
                  </div>
                </div>
                <div class="stat-item stat-success">
                  <div class="stat-icon-mini">
                    <font-awesome-icon icon="file-invoice-dollar" />
                  </div>
                  <div class="stat-details">
                    <div class="stat-value-mini">{{ ejercicioSeleccionado.total_adeudos || 0 }}</div>
                    <div class="stat-label-mini">Adeudos</div>
                  </div>
                </div>
                <div class="stat-item stat-warning">
                  <div class="stat-icon-mini">
                    <font-awesome-icon icon="receipt" />
                  </div>
                  <div class="stat-details">
                    <div class="stat-value-mini">{{ ejercicioSeleccionado.total_pagos || 0 }}</div>
                    <div class="stat-label-mini">Pagos</div>
                  </div>
                </div>
                <div class="stat-item stat-info">
                  <div class="stat-icon-mini">
                    <font-awesome-icon icon="money-bill-wave" />
                  </div>
                  <div class="stat-details">
                    <div class="stat-value-mini">${{ formatCurrency(ejercicioSeleccionado.monto_total || 0) }}</div>
                    <div class="stat-label-mini">Monto Total</div>
                  </div>
                </div>
              </div>

              <div class="d-flex gap-2">
                <button
                  class="btn-municipal-primary"
                  @click="guardarEjercicio"
                  :disabled="!validarFormEjercicio || guardando"
                >
                  <font-awesome-icon icon="save" class="me-1" />
                  <span v-if="!guardando">{{ modoEdicion ? 'Actualizar' : 'Crear Ejercicio' }}</span>
                  <span v-else>
                    <span class="spinner-border spinner-border-sm me-1"></span>
                    Guardando...
                  </span>
                </button>
                <button class="btn-municipal-secondary" @click="cancelarEdicion" v-if="modoEdicion">
                  <font-awesome-icon icon="times" class="me-1" />
                  Cancelar
                </button>
                <button
                  class="btn-municipal-secondary ms-auto"
                  @click="cerrarEjercicio"
                  v-if="modoEdicion && ejercicioSeleccionado?.activo"
                >
                  <font-awesome-icon icon="lock" class="me-1" />
                  Cerrar Ejercicio
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Periodos -->
    <div v-if="tabActual === 'periodos'">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <div class="d-flex justify-content-between align-items-center">
            <h6 class="mb-0">Periodos de Facturación</h6>
            <div>
              <select class="municipal-form-control form-select-sm" v-model="ejercicioFiltro" @change="cargarPeriodos">
                <option value="">Seleccione ejercicio...</option>
                <option v-for="ej in ejercicios" :key="ej.ejercicio" :value="ej.ejercicio">
                  {{ ej.ejercicio }}
                </option>
              </select>
            </div>
          </div>
        </div>
        <div class="municipal-card-body">
          <div v-if="ejercicioFiltro">
            <div class="d-flex justify-content-between align-items-center mb-3">
              <h6 class="mb-0">Periodos del Ejercicio {{ ejercicioFiltro }}</h6>
              <button class="btn-municipal-primary btn-sm" @click="nuevoPeriodo">
                <font-awesome-icon icon="plus" class="me-1" />
                Nuevo Periodo
              </button>
            </div>

            <div v-if="periodos.length > 0">
              <div class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Periodo</th>
                      <th>Descripción</th>
                      <th>Fecha Inicio</th>
                      <th>Fecha Fin</th>
                      <th>Fecha Vencimiento</th>
                      <th>Status</th>
                      <th>Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="periodo in periodos" :key="periodo.id">
                      <td><strong>{{ periodo.periodo }}</strong></td>
                      <td>{{ periodo.descripcion }}</td>
                      <td>{{ formatFecha(periodo.fecha_inicio) }}</td>
                      <td>{{ formatFecha(periodo.fecha_fin) }}</td>
                      <td>{{ formatFecha(periodo.fecha_vencimiento) }}</td>
                      <td>
                        <span class="badge" :class="{
                          'bg-success': periodo.status === 'ABIERTO',
                          'bg-warning': periodo.status === 'PROCESO',
                          'bg-secondary': periodo.status === 'CERRADO'
                        }">
                          {{ periodo.status }}
                        </span>
                      </td>
                      <td>
                        <button
                          class="btn btn-sm btn-primary me-1"
                          @click="editarPeriodo(periodo)"
                          title="Editar"
                        >
                          <font-awesome-icon icon="edit" />
                        </button>
                        <button
                          class="btn btn-sm btn-danger"
                          @click="eliminarPeriodo(periodo)"
                          v-if="periodo.status === 'ABIERTO'"
                          title="Eliminar"
                        >
                          <font-awesome-icon icon="trash" />
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
            <div v-else class="municipal-alert municipal-alert-info">
              <font-awesome-icon icon="info-circle" class="me-2" />
              No hay periodos registrados para este ejercicio.
            </div>
          </div>
          <div v-else class="municipal-alert municipal-alert-warning">
            <font-awesome-icon icon="exclamation-triangle" class="me-2" />
            Seleccione un ejercicio para ver sus periodos.
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Tarifas por Ejercicio -->
    <div v-if="tabActual === 'tarifas'">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <div class="d-flex justify-content-between align-items-center">
            <h6 class="mb-0">Tarifas por Ejercicio Fiscal</h6>
            <div>
              <select class="municipal-form-control form-select-sm" v-model="ejercicioTarifas" @change="cargarTarifas">
                <option value="">Seleccione ejercicio...</option>
                <option v-for="ej in ejercicios" :key="ej.ejercicio" :value="ej.ejercicio">
                  {{ ej.ejercicio }}
                </option>
              </select>
            </div>
          </div>
        </div>
        <div class="municipal-card-body">
          <div v-if="ejercicioTarifas">
            <div class="d-flex justify-content-between align-items-center mb-3">
              <h6 class="mb-0">Tarifas del Ejercicio {{ ejercicioTarifas }}</h6>
              <div class="btn-group">
                <button class="btn-municipal-primary btn-sm" @click="nuevaTarifa">
                  <font-awesome-icon icon="plus" class="me-1" />
                  Nueva Tarifa
                </button>
                <button class="btn-municipal-info btn-sm" @click="copiarTarifas">
                  <font-awesome-icon icon="copy" class="me-1" />
                  Copiar de Ejercicio Anterior
                </button>
              </div>
            </div>

            <div v-if="tarifas.length > 0">
              <div class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Tipo de Aseo</th>
                      <th>Descripción</th>
                      <th class="text-end">Cuota Mensual</th>
                      <th class="text-end">Recargo (%)</th>
                      <th class="text-end">Gastos Cobranza</th>
                      <th>Vigencia</th>
                      <th>Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="tarifa in tarifas" :key="tarifa.id">
                      <td><strong>{{ formatTipoAseo(tarifa.tipo_aseo) }}</strong></td>
                      <td>{{ tarifa.descripcion }}</td>
                      <td class="text-end">${{ formatCurrency(tarifa.cuota_mensual) }}</td>
                      <td class="text-end">{{ tarifa.porcentaje_recargo }}%</td>
                      <td class="text-end">${{ formatCurrency(tarifa.gastos_cobranza) }}</td>
                      <td>
                        <small>
                          {{ formatFecha(tarifa.fecha_inicio) }} -
                          {{ formatFecha(tarifa.fecha_fin) }}
                        </small>
                      </td>
                      <td>
                        <button
                          class="btn btn-sm btn-primary me-1"
                          @click="editarTarifa(tarifa)"
                          title="Editar"
                        >
                          <font-awesome-icon icon="edit" />
                        </button>
                        <button
                          class="btn btn-sm btn-danger"
                          @click="eliminarTarifa(tarifa)"
                          title="Eliminar"
                        >
                          <font-awesome-icon icon="trash" />
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
            <div v-else class="municipal-alert municipal-alert-info">
              <font-awesome-icon icon="info-circle" class="me-2" />
              No hay tarifas configuradas para este ejercicio.
            </div>
          </div>
          <div v-else class="municipal-alert municipal-alert-warning">
            <font-awesome-icon icon="exclamation-triangle" class="me-2" />
            Seleccione un ejercicio para ver sus tarifas.
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal
      v-if="mostrarAyuda"
      :show="mostrarAyuda"
      @close="mostrarAyuda = false"
      title="Gestión de Ejercicios Fiscales - Ayuda"
    >
      <h6>Descripción</h6>
      <p>
        Este módulo permite administrar los ejercicios fiscales, periodos de facturación y tarifas
        aplicables para el servicio de aseo contratado.
      </p>

      <h6>Ejercicios Fiscales</h6>
      <ul>
        <li><strong>Ejercicio:</strong> Año fiscal completo con sus configuraciones</li>
        <li><strong>Periodos:</strong> División del ejercicio (mensual, quincenal, etc.)</li>
        <li><strong>Tarifas:</strong> Costos aplicables durante el ejercicio</li>
      </ul>

      <h6>Periodos de Facturación</h6>
      <p>
        Los periodos determinan los ciclos de cobro. Pueden ser mensuales (12), quincenales (24),
        semanales (52), etc. Cada periodo tiene fechas de inicio, fin y vencimiento.
      </p>

      <h6>Tarifas por Ejercicio</h6>
      <p>
        Las tarifas definen los costos del servicio por tipo de aseo. Se pueden copiar del ejercicio
        anterior y ajustar según las necesidades del nuevo ejercicio.
      </p>

      <h6>Consideraciones</h6>
      <ul>
        <li>Solo puede haber un ejercicio activo a la vez</li>
        <li>Los periodos se generan automáticamente al crear el ejercicio</li>
        <li>Las tarifas deben configurarse antes de generar adeudos</li>
        <li>Un ejercicio cerrado no puede modificarse</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'EjerciciosGestion'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'

const { showLoading, hideLoading } = useGlobalLoading()

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()
const { showToast } = useToast()

// Estado
const tabActual = ref('ejercicios')
const guardando = ref(false)
const mostrarAyuda = ref(false)
const modoEdicion = ref(false)

// Ejercicios
const ejercicios = ref([])
const ejercicioSeleccionado = ref(null)
const ejercicioActual = ref(new Date().getFullYear())
const formEjercicio = ref({
  ejercicio: new Date().getFullYear(),
  num_periodos: 12,
  fecha_inicio: `${new Date().getFullYear()}-01-01`,
  fecha_fin: `${new Date().getFullYear()}-12-31`,
  descripcion: '',
  activo: true,
  generar_periodos_auto: true
})

// Periodos
const ejercicioFiltro = ref('')
const periodos = ref([])

// Tarifas
const ejercicioTarifas = ref('')
const tarifas = ref([])

// Computed
const validarFormEjercicio = computed(() => {
  return formEjercicio.value.ejercicio &&
         formEjercicio.value.num_periodos > 0 &&
         formEjercicio.value.fecha_inicio &&
         formEjercicio.value.fecha_fin
})

// Métodos - Ejercicios
const cargarEjercicios = async () => {
  try {
    const response = await execute('SP_ASEO_EJERCICIOS_LISTAR', 'aseo_contratado', {})
    ejercicios.value = response || []

    // Determinar ejercicio actual
    const actual = ejercicios.value.find(e => e.activo)
    if (actual) {
      ejercicioActual.value = actual.ejercicio
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar ejercicios')
    ejercicios.value = []
  }
}

const seleccionarEjercicio = async (ejercicio) => {
  ejercicioSeleccionado.value = ejercicio
  formEjercicio.value = { ...ejercicio }
  modoEdicion.value = true

  // Cargar estadísticas
  try {
    const stats = await execute('SP_ASEO_EJERCICIO_ESTADISTICAS', 'aseo_contratado', {
      p_ejercicio: ejercicio.ejercicio
    })
    if (stats && stats.length > 0) {
      ejercicioSeleccionado.value = { ...ejercicio, ...stats[0] }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const nuevoEjercicio = () => {
  ejercicioSeleccionado.value = null
  const siguienteEjercicio = Math.max(...ejercicios.value.map(e => e.ejercicio), new Date().getFullYear()) + 1
  formEjercicio.value = {
    ejercicio: siguienteEjercicio,
    num_periodos: 12,
    fecha_inicio: `${siguienteEjercicio}-01-01`,
    fecha_fin: `${siguienteEjercicio}-12-31`,
    descripcion: `Ejercicio Fiscal ${siguienteEjercicio}`,
    activo: false,
    generar_periodos_auto: true
  }
  modoEdicion.value = false
}

const guardarEjercicio = async () => {
  guardando.value = true
  try {
    const sp = modoEdicion.value ? 'SP_ASEO_EJERCICIO_ACTUALIZAR' : 'SP_ASEO_EJERCICIO_INSERTAR'

    await execute(sp, 'aseo_contratado', {
      p_ejercicio: formEjercicio.value.ejercicio,
      p_num_periodos: formEjercicio.value.num_periodos,
      p_fecha_inicio: formEjercicio.value.fecha_inicio,
      p_fecha_fin: formEjercicio.value.fecha_fin,
      p_descripcion: formEjercicio.value.descripcion,
      p_activo: formEjercicio.value.activo ? 'S' : 'N',
      p_generar_periodos: formEjercicio.value.generar_periodos_auto ? 'S' : 'N'
    })

    showToast(
      modoEdicion.value ? 'Ejercicio actualizado exitosamente' : 'Ejercicio creado exitosamente',
      'success'
    )
    await cargarEjercicios()
    nuevoEjercicio()
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al guardar ejercicio')
  } finally {
    guardando.value = false
  }
}

const cancelarEdicion = () => {
  nuevoEjercicio()
}

const cerrarEjercicio = async () => {
  const result = await Swal.fire({
    title: '¿Cerrar Ejercicio?',
    html: `
      <p>Se cerrará el ejercicio <strong>${ejercicioSeleccionado.value.ejercicio}</strong></p>
      <p class="text-danger">Esta acción es IRREVERSIBLE.</p>
      <p>No se podrán generar más adeudos ni modificar información del ejercicio.</p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    confirmButtonText: 'Sí, Cerrar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    try {
      await execute('SP_ASEO_EJERCICIO_CERRAR', 'aseo_contratado', {
        p_ejercicio: ejercicioSeleccionado.value.ejercicio
      })

      showToast('Ejercicio cerrado exitosamente', 'success')
      await cargarEjercicios()
      nuevoEjercicio()
    } catch (error) {
      hideLoading()
      handleApiError(error, 'Error al cerrar ejercicio')
    }
  }
}

// Métodos - Periodos
const cargarPeriodos = async () => {
  if (!ejercicioFiltro.value) {
    periodos.value = []
    return
  }

  try {
    const response = await execute('SP_ASEO_PERIODOS_LISTAR', 'aseo_contratado', {
      p_ejercicio: ejercicioFiltro.value
    })
    periodos.value = response || []
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar periodos')
    periodos.value = []
  }
}

const nuevoPeriodo = async () => {
  // Implementar modal o formulario para nuevo periodo
  showToast('Funcionalidad en desarrollo', 'info')
}

const editarPeriodo = (periodo) => {
  showToast('Funcionalidad en desarrollo', 'info')
}

const eliminarPeriodo = async (periodo) => {
  const result = await Swal.fire({
    title: '¿Eliminar Periodo?',
    text: `Se eliminará el periodo ${periodo.periodo}`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    confirmButtonText: 'Sí, Eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    try {
      await execute('SP_ASEO_PERIODO_ELIMINAR', 'aseo_contratado', {
        p_id: periodo.id
      })

      showToast('Periodo eliminado exitosamente', 'success')
      await cargarPeriodos()
    } catch (error) {
      hideLoading()
      handleApiError(error, 'Error al eliminar periodo')
    }
  }
}

// Métodos - Tarifas
const cargarTarifas = async () => {
  if (!ejercicioTarifas.value) {
    tarifas.value = []
    return
  }

  try {
    const response = await execute('SP_ASEO_TARIFAS_LISTAR', 'aseo_contratado', {
      p_ejercicio: ejercicioTarifas.value
    })
    tarifas.value = response || []
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar tarifas')
    tarifas.value = []
  }
}

const nuevaTarifa = () => {
  showToast('Funcionalidad en desarrollo', 'info')
}

const editarTarifa = (tarifa) => {
  showToast('Funcionalidad en desarrollo', 'info')
}

const eliminarTarifa = async (tarifa) => {
  const result = await Swal.fire({
    title: '¿Eliminar Tarifa?',
    text: `Se eliminará la tarifa para ${formatTipoAseo(tarifa.tipo_aseo)}`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    confirmButtonText: 'Sí, Eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    try {
      await execute('SP_ASEO_TARIFA_ELIMINAR', 'aseo_contratado', {
        p_id: tarifa.id
      })

      showToast('Tarifa eliminada exitosamente', 'success')
      await cargarTarifas()
    } catch (error) {
      hideLoading()
      handleApiError(error, 'Error al eliminar tarifa')
    }
  }
}

const copiarTarifas = async () => {
  const ejercicioAnterior = parseInt(ejercicioTarifas.value) - 1

  const result = await Swal.fire({
    title: 'Copiar Tarifas',
    html: `
      <p>¿Desea copiar las tarifas del ejercicio <strong>${ejercicioAnterior}</strong>?</p>
      <p class="text-muted">Se copiarán todas las tarifas al ejercicio ${ejercicioTarifas.value}</p>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    confirmButtonText: 'Sí, Copiar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    try {
      await execute('SP_ASEO_TARIFAS_COPIAR', 'aseo_contratado', {
        p_ejercicio_origen: ejercicioAnterior,
        p_ejercicio_destino: ejercicioTarifas.value
      })

      showToast('Tarifas copiadas exitosamente', 'success')
      await cargarTarifas()
    } catch (error) {
      hideLoading()
      handleApiError(error, 'Error al copiar tarifas')
    }
  }
}

// Formatters
const formatTipoAseo = (tipo) => {
  const tipos = {
    'D': 'Doméstico',
    'C': 'Comercial',
    'I': 'Industrial',
    'S': 'Servicios',
    'E': 'Especial'
  }
  return tipos[tipo] || tipo
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value || 0)
}

const formatFecha = (fecha) => {
  if (!fecha) return 'N/A'
  return new Date(fecha).toLocaleDateString('es-MX')
}

// Inicialización
onMounted(() => {
  cargarEjercicios()
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

