<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-days" />
      </div>
      <div class="module-view-info">
        <h1>Actualización de Periodos de Contratos</h1>
        <p>Aseo Contratado - Modificación masiva de periodos de facturación</p>
      </div>
    </div>

    <!-- Paso 1: Filtros de Búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5><font-awesome-icon icon="filter" class="me-2" />Paso 1: Selección de Contratos</h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Empresa</label>
            <select class="form-control" v-model="filtros.empresa">
              <option value="">Todas las empresas</option>
              <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                {{ emp.nombre_empresa }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Tipo de Aseo</label>
            <select class="form-control" v-model="filtros.tipoAseo">
              <option value="">Todos</option>
              <option v-for="tipo in tiposAseo" :key="tipo.cve_tipoaseo" :value="tipo.cve_tipoaseo">
                {{ tipo.tipo_aseo }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Zona</label>
            <select class="form-control" v-model="filtros.zona">
              <option value="">Todas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Periodo Actual</label>
            <input
              type="text"
              class="form-control"
              v-model="filtros.periodoActual"
              placeholder="YYYYMM (ej: 202401)"
              maxlength="6"
            />
          </div>
          <div class="form-group" style="align-self: flex-end;">
            <button class="btn-municipal-info" @click="buscarContratos">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de Contratos -->
    <div v-if="contratos.length > 0" class="municipal-card">
      <div class="municipal-card-header d-flex justify-content-between align-items-center">
        <h5><font-awesome-icon icon="list" class="me-2" />Contratos Encontrados ({{ contratos.length }})</h5>
        <div class="button-group">
          <button class="btn-municipal-success btn-sm" @click="seleccionarTodos">
            <font-awesome-icon icon="check-double" /> Todos
          </button>
          <button class="btn-municipal-secondary btn-sm" @click="limpiarSeleccion">
            <font-awesome-icon icon="eraser" /> Limpiar
          </button>
        </div>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
          <table class="municipal-table">
            <thead>
              <tr>
                <th style="width: 40px;">
                  <input
                    type="checkbox"
                    v-model="seleccionarTodo"
                    @change="toggleSeleccionTodos"
                  />
                </th>
                <th>Contrato</th>
                <th>Contribuyente</th>
                <th>Empresa</th>
                <th>Tipo Aseo</th>
                <th>Zona</th>
                <th>Periodo Actual</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="contrato in contratos"
                :key="contrato.control_contrato"
                :class="{ 'table-row-selected': contratosSeleccionados.includes(contrato.control_contrato) }"
              >
                <td>
                  <input
                    type="checkbox"
                    :value="contrato.control_contrato"
                    v-model="contratosSeleccionados"
                  />
                </td>
                <td>{{ contrato.num_contrato }}</td>
                <td>{{ contrato.contribuyente }}</td>
                <td>{{ contrato.nombre_empresa }}</td>
                <td>{{ contrato.tipo_aseo }}</td>
                <td>{{ contrato.zona }}</td>
                <td>
                  <span class="badge badge-info">
                    {{ formatPeriodo(contrato.periodo) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Mensaje sin resultados -->
    <div v-else-if="busquedaRealizada" class="municipal-card">
      <div class="municipal-card-body">
        <div class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="file-contract" />
          </div>
          <h4 class="empty-state-title">No se encontraron contratos</h4>
          <p class="empty-state-description">
            No hay contratos que coincidan con los filtros de búsqueda especificados.
          </p>
          <div class="empty-state-suggestions">
            <p><strong>Sugerencias:</strong></p>
            <ul>
              <li>Verifique que el periodo tenga formato correcto (YYYYMM)</li>
              <li>Intente ampliar los criterios de búsqueda</li>
              <li>Seleccione "Todas" en los filtros de empresa, tipo o zona</li>
            </ul>
          </div>
          <button class="btn-municipal-secondary mt-3" @click="limpiarFiltros">
            <font-awesome-icon icon="eraser" /> Limpiar Filtros
          </button>
        </div>
      </div>
    </div>

    <!-- Estado inicial - Sin búsqueda -->
    <div v-else-if="!busquedaRealizada" class="municipal-card">
      <div class="municipal-card-body">
        <div class="empty-state initial-state">
          <div class="empty-state-icon pulse">
            <font-awesome-icon icon="search" />
          </div>
          <h4 class="empty-state-title">Busque contratos para actualizar</h4>
          <p class="empty-state-description">
            Utilice los filtros anteriores para buscar los contratos a los que desea
            actualizar el periodo de facturación.
          </p>
          <div class="empty-state-steps">
            <div class="step">
              <div class="step-number">1</div>
              <div class="step-text">Seleccione los filtros deseados</div>
            </div>
            <div class="step">
              <div class="step-number">2</div>
              <div class="step-text">Haga clic en "Buscar"</div>
            </div>
            <div class="step">
              <div class="step-number">3</div>
              <div class="step-text">Seleccione los contratos a actualizar</div>
            </div>
            <div class="step">
              <div class="step-number">4</div>
              <div class="step-text">Ingrese el nuevo periodo y aplique</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Paso 2: Actualización de Periodo -->
    <div v-if="contratosSeleccionados.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="calendar-alt" class="me-2" />
          Paso 2: Actualización de Periodo ({{ contratosSeleccionados.length }} seleccionados)
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="municipal-alert municipal-alert-warning mb-3">
          <font-awesome-icon icon="exclamation-triangle" class="me-2" />
          Esta operación actualizará el periodo de facturación de los contratos seleccionados.
        </div>

        <div class="form-row">
          <div class="form-group">
            <label class="form-label required">Nuevo Periodo</label>
            <input
              type="text"
              class="form-control"
              v-model="nuevoPeriodo"
              placeholder="YYYYMM (ej: 202402)"
              maxlength="6"
              @input="validarPeriodoInput"
            />
            <small class="text-muted">Formato: Año (4 dígitos) + Mes (2 dígitos)</small>
          </div>
          <div class="form-group">
            <label class="form-label">O Seleccionar Fecha</label>
            <input
              type="month"
              class="form-control"
              v-model="fechaSeleccionada"
              @change="actualizarDesdeFecha"
            />
          </div>
          <div class="form-group" style="flex: 2;">
            <label class="form-label required">Motivo de la Actualización</label>
            <input
              type="text"
              class="form-control"
              v-model="motivo"
              placeholder="Ej: Ajuste de periodo por cambio de ciclo de facturación"
            />
          </div>
        </div>

        <div v-if="nuevoPeriodo && periodoValido" class="municipal-alert municipal-alert-info mb-3">
          <strong>Periodo a asignar:</strong> {{ formatPeriodo(nuevoPeriodo) }}
        </div>

        <div v-if="nuevoPeriodo && !periodoValido" class="municipal-alert municipal-alert-danger mb-3">
          <font-awesome-icon icon="exclamation-circle" class="me-2" />
          El periodo ingresado no es válido. Debe ser formato YYYYMM con año entre 2000-2099 y mes entre 01-12.
        </div>

        <div class="form-actions">
          <button class="btn-municipal-secondary" @click="cancelar">
            <font-awesome-icon icon="times" /> Cancelar
          </button>
          <button
            class="btn-municipal-warning"
            @click="actualizarPeriodos"
            :disabled="!validarActualizacion()"
          >
            <font-awesome-icon icon="save" /> Actualizar Periodos
          </button>
        </div>
      </div>
    </div>

    <!-- Resultado de la operación -->
    <div v-if="resultado" class="municipal-card">
      <div class="municipal-card-header" :class="resultado.success ? 'bg-success text-white' : 'bg-danger text-white'">
        <h5>
          <font-awesome-icon :icon="resultado.success ? 'check-circle' : 'exclamation-circle'" class="me-2" />
          Resultado de la Operación
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="row text-center">
          <div class="col-md-4">
            <div class="stat-box">
              <div class="stat-number">{{ resultado.contratos_procesados }}</div>
              <div class="stat-label">Contratos Procesados</div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="stat-box bg-success text-white">
              <div class="stat-number">{{ resultado.actualizaciones_exitosas }}</div>
              <div class="stat-label">Actualizados</div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="stat-box bg-danger text-white">
              <div class="stat-number">{{ resultado.errores }}</div>
              <div class="stat-label">Errores</div>
            </div>
          </div>
        </div>
        <p class="text-center mt-3">{{ resultado.message }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'public'

const { execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const contratos = ref([])
const empresas = ref([])
const tiposAseo = ref([])
const zonas = ref([])
const contratosSeleccionados = ref([])
const seleccionarTodo = ref(false)
const nuevoPeriodo = ref('')
const fechaSeleccionada = ref('')
const motivo = ref('')
const busquedaRealizada = ref(false)
const resultado = ref(null)

const filtros = ref({
  empresa: '',
  tipoAseo: '',
  zona: '',
  periodoActual: ''
})

// Computed
const periodoValido = computed(() => {
  if (!nuevoPeriodo.value || nuevoPeriodo.value.length !== 6) return false
  const anio = parseInt(nuevoPeriodo.value.substring(0, 4))
  const mes = parseInt(nuevoPeriodo.value.substring(4, 6))
  return anio >= 2000 && anio <= 2099 && mes >= 1 && mes <= 12
})

// Métodos
const cargarCatalogos = async () => {
  showLoading()
  try {
    const [respEmpresas, respTipos, respZonas] = await Promise.all([
      execute('sp_aseo_empresas_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_tipos_aseo_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_aseo_zonas_list', BASE_DB, [], '', null, SCHEMA)
    ])
    empresas.value = respEmpresas?.result || []
    tiposAseo.value = respTipos?.result || []
    zonas.value = respZonas?.result || []
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar catálogos')
  } finally {
    hideLoading()
  }
}

const buscarContratos = async () => {
  showLoading()
  busquedaRealizada.value = true
  resultado.value = null

  try {
    const params = []

    if (filtros.value.empresa) {
      params.push({ nombre: 'p_num_empresa', valor: parseInt(filtros.value.empresa), tipo: 'integer' })
    }
    if (filtros.value.tipoAseo) {
      params.push({ nombre: 'p_cve_tipoaseo', valor: filtros.value.tipoAseo, tipo: 'string' })
    }
    if (filtros.value.zona) {
      params.push({ nombre: 'p_zona', valor: filtros.value.zona, tipo: 'string' })
    }
    if (filtros.value.periodoActual) {
      params.push({ nombre: 'p_periodo', valor: filtros.value.periodoActual, tipo: 'string' })
    }

    const response = await execute('sp_aseo_contratos_list', BASE_DB, params, '', null, SCHEMA)
    contratos.value = response?.result || []
    contratosSeleccionados.value = []
    seleccionarTodo.value = false

    showToast(`${contratos.value.length} contrato(s, 'success') encontrado(s)`)
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar contratos')
    contratos.value = []
  } finally {
    hideLoading()
  }
}

const seleccionarTodos = () => {
  contratosSeleccionados.value = contratos.value.map(c => c.control_contrato)
  seleccionarTodo.value = true
}

const limpiarSeleccion = () => {
  contratosSeleccionados.value = []
  seleccionarTodo.value = false
}

const toggleSeleccionTodos = () => {
  if (seleccionarTodo.value) {
    seleccionarTodos()
  } else {
    limpiarSeleccion()
  }
}

const validarPeriodoInput = () => {
  // Solo permitir números
  nuevoPeriodo.value = nuevoPeriodo.value.replace(/\D/g, '')
}

const actualizarDesdeFecha = () => {
  if (fechaSeleccionada.value) {
    const [anio, mes] = fechaSeleccionada.value.split('-')
    nuevoPeriodo.value = `${anio}${mes}`
  }
}

const validarActualizacion = () => {
  if (contratosSeleccionados.value.length === 0) return false
  if (!periodoValido.value) return false
  if (!motivo.value.trim()) return false
  return true
}

const formatPeriodo = (periodo) => {
  if (!periodo || periodo.length !== 6) return periodo || 'Sin asignar'
  const anio = periodo.substring(0, 4)
  const mes = periodo.substring(4, 6)
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  const mesNombre = meses[parseInt(mes) - 1]
  return `${mesNombre} ${anio}`
}

const actualizarPeriodos = async () => {
  const confirmResult = await Swal.fire({
    title: '¿Actualizar Periodos?',
    html: `Se actualizarán <strong>${contratosSeleccionados.value.length}</strong> contrato(s)<br>
           Nuevo periodo: <strong>${formatPeriodo(nuevoPeriodo.value)}</strong>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#ffc107',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  showLoading()

  let actualizados = 0
  let errores = 0

  try {
    for (const controlContrato of contratosSeleccionados.value) {
      try {
        const params = [
          { nombre: 'p_control_contrato', valor: controlContrato, tipo: 'integer' },
          { nombre: 'p_periodo', valor: nuevoPeriodo.value, tipo: 'string' }
        ]

        const response = await execute('sp_aseo_contratos_update', BASE_DB, params, '', null, SCHEMA)

        if (response?.result?.[0]?.success === false) {
          errores++
        } else {
          actualizados++
        }
      } catch {
        errores++
      }
    }

    hideLoading()

    resultado.value = {
      success: errores === 0,
      message: errores === 0
        ? 'Todos los periodos fueron actualizados correctamente'
        : `Completado con ${errores} error(es)`,
      contratos_procesados: contratosSeleccionados.value.length,
      actualizaciones_exitosas: actualizados,
      errores: errores
    }

    await Swal.fire(
      '¡Proceso completado!',
      `Actualizados: ${actualizados}, Errores: ${errores}`,
      errores === 0 ? 'success' : 'warning'
    )

    // Refrescar lista
    await buscarContratos()
    cancelar()

  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al actualizar periodos')
  }
}

const cancelar = () => {
  contratosSeleccionados.value = []
  nuevoPeriodo.value = ''
  fechaSeleccionada.value = ''
  motivo.value = ''
  seleccionarTodo.value = false
}

const limpiarFiltros = () => {
  filtros.value = {
    empresa: '',
    tipoAseo: '',
    zona: '',
    periodoActual: ''
  }
  contratos.value = []
  busquedaRealizada.value = false
  resultado.value = null
}

onMounted(() => {
  cargarCatalogos()
})
</script>

