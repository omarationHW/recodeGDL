<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="truck" />
      </div>
      <div class="module-view-info">
        <h1>Actualización de Unidad Recolectora</h1>
        <p>Aseo Contratado - Cambio de unidad de recolección por contrato</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Paso 1: Búsqueda de Contrato -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Paso 1: Búsqueda de Contrato
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Contrato <span class="required">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="numContrato"
                placeholder="Ingrese número de contrato"
                @keyup.enter="buscarContrato"
                :disabled="contratoEncontrado"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Aseo</label>
              <select
                class="municipal-form-control"
                v-model="tipoAseoSeleccionado"
                :disabled="contratoEncontrado"
              >
                <option :value="null">-- Todos --</option>
                <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
                  {{ tipo.tipo_aseo }} - {{ tipo.descripcion }}
                </option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarContrato"
              :disabled="!numContrato || contratoEncontrado"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button
              v-if="contratoEncontrado"
              class="btn-municipal-secondary"
              @click="limpiarBusqueda"
            >
              <font-awesome-icon icon="times" />
              Nueva Búsqueda
            </button>
          </div>
        </div>
      </div>

      <!-- Estado Vacío - Sin búsqueda -->
      <div v-if="!contratoEncontrado && !buscando" class="municipal-card">
        <div class="municipal-card-body">
          <div class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="file-contract" />
            </div>
            <h4>Buscar Contrato para Actualizar Unidad</h4>
            <p>Ingrese el número de contrato para cambiar la unidad de recolección asignada</p>

            <div class="steps-guide">
              <div class="step-item">
                <div class="step-number">1</div>
                <div class="step-content">
                  <strong>Buscar contrato</strong>
                  <span>Ingrese el número de contrato vigente</span>
                </div>
              </div>
              <div class="step-item">
                <div class="step-number">2</div>
                <div class="step-content">
                  <strong>Verificar datos</strong>
                  <span>Confirme que es el contrato correcto</span>
                </div>
              </div>
              <div class="step-item">
                <div class="step-number">3</div>
                <div class="step-content">
                  <strong>Seleccionar nueva unidad</strong>
                  <span>Elija la unidad de recolección a asignar</span>
                </div>
              </div>
              <div class="step-item">
                <div class="step-number">4</div>
                <div class="step-content">
                  <strong>Documentar cambio</strong>
                  <span>Registre el documento que avala la modificación</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del Contrato Encontrado -->
      <template v-if="contratoEncontrado">
        <div class="municipal-card">
          <div class="municipal-card-header header-success">
            <h5>
              <font-awesome-icon icon="check-circle" />
              Contrato Encontrado - #{{ contrato.num_contrato }}
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="info-cards-grid">
              <!-- Datos del Contrato -->
              <div class="info-card">
                <h6 class="info-card-title">
                  <font-awesome-icon icon="file-contract" class="icon-primary" />
                  Datos del Contrato
                </h6>
                <div class="info-grid">
                  <div class="info-item">
                    <span class="info-label">Control:</span>
                    <span class="info-value"><code>{{ contrato.control_contrato }}</code></span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Contrato:</span>
                    <span class="info-value"><strong>{{ contrato.num_contrato }}</strong></span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Fecha Inicio:</span>
                    <span class="info-value">{{ formatDate(contrato.fecha_inicio) }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Estado:</span>
                    <span class="badge-success">{{ contrato.status_vigencia === 'V' ? 'VIGENTE' : contrato.status_vigencia }}</span>
                  </div>
                </div>
              </div>

              <!-- Datos de la Empresa -->
              <div class="info-card">
                <h6 class="info-card-title">
                  <font-awesome-icon icon="building" class="icon-info" />
                  Empresa
                </h6>
                <div class="info-grid">
                  <div class="info-item">
                    <span class="info-label">Número:</span>
                    <span class="info-value">{{ contrato.num_empresa }}</span>
                  </div>
                  <div class="info-item full-width">
                    <span class="info-label">Nombre:</span>
                    <span class="info-value">{{ contrato.nombre_empresa }}</span>
                  </div>
                  <div class="info-item full-width">
                    <span class="info-label">Tipo:</span>
                    <span class="info-value">{{ contrato.tipo_empresa }}</span>
                  </div>
                </div>
              </div>

              <!-- Tipo de Aseo -->
              <div class="info-card">
                <h6 class="info-card-title">
                  <font-awesome-icon icon="recycle" class="icon-success" />
                  Tipo de Aseo
                </h6>
                <div class="info-grid">
                  <div class="info-item">
                    <span class="info-label">Código:</span>
                    <span class="info-value"><code>{{ contrato.tipo_aseo }}</code></span>
                  </div>
                  <div class="info-item full-width">
                    <span class="info-label">Descripción:</span>
                    <span class="info-value">{{ contrato.descripcion_aseo }}</span>
                  </div>
                </div>
              </div>

              <!-- Unidad Actual -->
              <div class="info-card highlight-warning">
                <h6 class="info-card-title">
                  <font-awesome-icon icon="truck" class="icon-warning" />
                  Unidad de Recolección Actual
                </h6>
                <div class="info-grid">
                  <div class="info-item">
                    <span class="info-label">Clave:</span>
                    <span class="info-value"><strong>{{ contrato.cve_recolec || 'Sin asignar' }}</strong></span>
                  </div>
                  <div class="info-item full-width">
                    <span class="info-label">Descripción:</span>
                    <span class="info-value">{{ contrato.descripcion_recolec || 'N/A' }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Paso 2: Actualización de Unidad -->
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="edit" />
              Paso 2: Asignación de Nueva Unidad
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="alert-info-box">
              <font-awesome-icon icon="info-circle" />
              <span>Seleccione la nueva unidad de recolección y registre el documento que avala el cambio.</span>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Nueva Unidad de Recolección <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="nuevaUnidad">
                  <option :value="null">-- Seleccione una unidad --</option>
                  <option
                    v-for="unidad in unidadesDisponibles"
                    :key="unidad.control_unidad"
                    :value="unidad.control_unidad"
                  >
                    {{ unidad.num_unidad }} - {{ unidad.tipo_unidad }}
                    <template v-if="unidad.capacidad">(Cap: {{ unidad.capacidad }})</template>
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Cantidad de Unidades</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model="cantidadUnidades"
                  min="1"
                  placeholder="1"
                />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Documento que Avala <span class="required">*</span></label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="documento"
                  placeholder="Ej: OFICIO-2025-001"
                />
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Ejercicio</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model="ejercicio"
                  :min="2020"
                  :max="new Date().getFullYear() + 1"
                />
              </div>
            </div>

            <div class="form-group full-width">
              <label class="municipal-form-label">Descripción / Motivo del Cambio <span class="required">*</span></label>
              <textarea
                class="municipal-form-control"
                v-model="conceptoDocumento"
                rows="3"
                placeholder="Describa el motivo del cambio de unidad de recolección..."
              ></textarea>
            </div>

            <!-- Preview del cambio -->
            <div v-if="nuevaUnidad" class="alert-warning-box">
              <font-awesome-icon icon="exchange-alt" />
              <div class="change-preview">
                <strong>Cambio a realizar:</strong>
                <div class="change-badges">
                  <span class="badge-secondary">{{ contrato.cve_recolec || 'Sin asignar' }}</span>
                  <font-awesome-icon icon="arrow-right" class="arrow-icon" />
                  <span class="badge-primary">{{ obtenerNombreUnidad(nuevaUnidad) }}</span>
                </div>
              </div>
            </div>

            <!-- Botones de acción -->
            <div class="button-group button-group-right">
              <button class="btn-municipal-secondary" @click="limpiarBusqueda">
                <font-awesome-icon icon="times" />
                Cancelar
              </button>
              <button
                class="btn-municipal-success"
                @click="actualizarUnidad"
                :disabled="!puedeActualizar"
              >
                <font-awesome-icon icon="save" />
                Actualizar Unidad
              </button>
            </div>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

// Estado de búsqueda
const numContrato = ref(null)
const tipoAseoSeleccionado = ref(null)
const buscando = ref(false)

// Catálogos
const tiposAseo = ref([])
const unidades = ref([])

// Contrato encontrado
const contrato = ref(null)
const contratoEncontrado = computed(() => contrato.value !== null)

// Datos para actualización
const nuevaUnidad = ref(null)
const cantidadUnidades = ref(1)
const documento = ref('')
const conceptoDocumento = ref('')
const ejercicio = ref(new Date().getFullYear())

// Unidades disponibles (excluyendo la actual)
const unidadesDisponibles = computed(() => {
  if (!contrato.value) return unidades.value
  return unidades.value.filter(u => u.control_unidad !== contrato.value.ctrol_recolec)
})

// Validación para poder actualizar
const puedeActualizar = computed(() => {
  return nuevaUnidad.value &&
         documento.value.trim() &&
         conceptoDocumento.value.trim() &&
         cantidadUnidades.value > 0
})

// Cargar catálogos al montar
onMounted(async () => {
  await cargarCatalogos()
})

const cargarCatalogos = async () => {
  try {
    showLoading('Cargando catálogos...')

    const [resTipos, resUnidades] = await Promise.all([
      execute('sp_aseo_tipos_aseo_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_aseo_unidades_list', BASE_DB, [
        { nombre: 'p_num_unidad', valor: null, tipo: 'string' }
      ], '', null, SCHEMA)
    ])

    tiposAseo.value = resTipos || []
    unidades.value = resUnidades || []
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar catálogos')
  } finally {
    hideLoading()
  }
}

const buscarContrato = async () => {
  if (!numContrato.value) {
    showToast('Ingrese el número de contrato', 'warning')
    return
  }

  try {
    showLoading('Buscando contrato...')
    buscando.value = true

    const params = [
      { nombre: 'p_num_contrato', valor: numContrato.value, tipo: 'integer' },
      { nombre: 'p_ctrol_aseo', valor: tipoAseoSeleccionado.value, tipo: 'integer' }
    ]

    const resultado = await execute('sp_aseo_contrato_buscar_por_numero', BASE_DB, params, '', null, SCHEMA)

    if (resultado && resultado.length > 0) {
      contrato.value = resultado[0]
      cantidadUnidades.value = contrato.value.cantidad_recolec || 1
      showToast('Contrato encontrado', 'success')
    } else {
      hideLoading()
      await Swal.fire({
        icon: 'warning',
        title: 'Contrato no encontrado',
        text: 'No existe contrato vigente con ese número. Verifique e intente nuevamente.',
        confirmButtonColor: '#6c757d'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar contrato')
  } finally {
    hideLoading()
    buscando.value = false
  }
}

const actualizarUnidad = async () => {
  if (!puedeActualizar.value) {
    showToast('Complete todos los campos requeridos', 'warning')
    return
  }

  const unidadNombre = obtenerNombreUnidad(nuevaUnidad.value)

  const confirmacion = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar cambio de unidad?',
    html: `
      <p>Se actualizará la unidad de recolección del contrato <strong>#${contrato.value.num_contrato}</strong></p>
      <p><strong>Nueva unidad:</strong> ${unidadNombre}</p>
      <p><strong>Documento:</strong> ${documento.value}</p>
    `,
    showCancelButton: true,
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmacion.isConfirmed) return

  try {
    showLoading('Actualizando unidad...')

    const params = [
      { nombre: 'p_control_contrato', valor: contrato.value.control_contrato, tipo: 'integer' },
      { nombre: 'p_ctrol_recolec', valor: nuevaUnidad.value, tipo: 'integer' },
      { nombre: 'p_cantidad_recolec', valor: cantidadUnidades.value, tipo: 'integer' },
      { nombre: 'p_usuario', valor: 1, tipo: 'integer' },
      { nombre: 'p_documento', valor: documento.value, tipo: 'string' },
      { nombre: 'p_concepto', valor: conceptoDocumento.value, tipo: 'string' }
    ]

    const resultado = await execute('sp_aseo_contrato_actualizar_unidad', BASE_DB, params, '', null, SCHEMA)

    hideLoading()

    if (resultado && resultado[0]?.actualizado) {
      await Swal.fire({
        icon: 'success',
        title: 'Unidad actualizada',
        text: 'La unidad de recolección ha sido actualizada correctamente.',
        confirmButtonColor: '#28a745'
      })
      limpiarBusqueda()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: resultado?.[0]?.mensaje || 'No se pudo actualizar la unidad',
        confirmButtonColor: '#dc3545'
      })
    }
  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al actualizar unidad')
  }
}

const limpiarBusqueda = () => {
  numContrato.value = null
  tipoAseoSeleccionado.value = null
  contrato.value = null
  nuevaUnidad.value = null
  cantidadUnidades.value = 1
  documento.value = ''
  conceptoDocumento.value = ''
  ejercicio.value = new Date().getFullYear()
}

const obtenerNombreUnidad = (controlUnidad) => {
  const unidad = unidades.value.find(u => u.control_unidad === controlUnidad)
  return unidad ? `${unidad.num_unidad} - ${unidad.tipo_unidad}` : ''
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('es-MX')
}
</script>

