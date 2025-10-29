<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="wrench" />
      </div>
      <div class="module-view-info">
        <h1>Actualización General de Contratos</h1>
        <p>Aseo Contratado - Modificación masiva de datos de contratos</p>
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
<div class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header">
        <h5>Paso 1: Selección de Contratos</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row mb-3">
          <div class="col-md-2">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="filtros.zona">
              <option value="">Todas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }}
              </option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="filtros.tipoAseo">
              <option value="">Todos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Empresa</label>
            <select class="municipal-form-control" v-model="filtros.empresa">
              <option value="">Todas</option>
              <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                {{ emp.nombre_empresa }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Rango de Contratos</label>
            <div class="input-group">
              <input type="text" class="municipal-form-control" v-model="filtros.contratoDesde" placeholder="Desde" />
              <input type="text" class="municipal-form-control" v-model="filtros.contratoHasta" placeholder="Hasta" />
            </div>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-info w-100" @click="buscarContratos" :disabled="cargando">
              <font-awesome-icon icon="search" /> Buscar Contratos
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="contratos.length > 0">
      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Contratos para Actualizar ({{ contratos.length }})</h6>
          <div>
            <button class="btn btn-sm btn-success" @click="seleccionarTodos">
              <font-awesome-icon icon="check-double" /> Todos
            </button>
            <button class="btn btn-sm btn-secondary ms-2" @click="limpiarSeleccion">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive" style="max-height: 350px; overflow-y: auto;">
            <table class="municipal-table">
              <thead class="table-light" style="position: sticky; top: 0;">
                <tr>
                  <th style="width: 40px;">
                    <input type="checkbox" class="form-check-input" v-model="seleccionarTodo"
                      @change="toggleSeleccionTodos" />
                  </th>
                  <th>Contrato</th>
                  <th>Contribuyente</th>
                  <th>Zona</th>
                  <th>Tipo</th>
                  <th>Empresa</th>
                  <th class="text-end">Cuota Actual</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratos" :key="contrato.control_contrato"
                    :class="{ 'table-warning': contratosSeleccionados.includes(contrato.control_contrato) }">
                  <td>
                    <input type="checkbox" class="form-check-input"
                      :value="contrato.control_contrato" v-model="contratosSeleccionados" />
                  </td>
                  <td>{{ contrato.num_contrato }}</td>
                  <td>{{ contrato.contribuyente }}</td>
                  <td class="text-center">{{ contrato.zona }}</td>
                  <td class="text-center">{{ formatTipoAseo(contrato.tipo_aseo) }}</td>
                  <td>{{ contrato.nombre_empresa }}</td>
                  <td class="text-end">${{ formatCurrency(contrato.cuota_mensual) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="contratosSeleccionados.length > 0" class="municipal-card">
        <div class="municipal-card-header">
        <h5>Paso 2: Configurar Actualizaciones ({{ contratosSeleccionados.length }} seleccionados)</h5>
      </div>
        <div class="municipal-card-body">
          <div class="alert alert-warning">
            <font-awesome-icon icon="exclamation-triangle" class="me-2" />
            <strong>Importante:</strong> Solo se aplicarán los campos que tengan valor. Deje en blanco los que no desea modificar.
          </div>

          <div class="row mb-3">
            <div class="col-md-12">
              <h6 class="border-bottom pb-2">Cambios de Empresa y Zona</h6>
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">Nueva Empresa</label>
              <select class="municipal-form-control" v-model="actualizaciones.empresa">
                <option value="">No modificar</option>
                <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                  {{ emp.nombre_empresa }}
                </option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">Nueva Zona</label>
              <select class="municipal-form-control" v-model="actualizaciones.zona">
                <option value="">No modificar</option>
                <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                  Zona {{ z.zona }}
                </option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">Nueva Unidad Recolectora</label>
              <select class="municipal-form-control" v-model="actualizaciones.unidad">
                <option value="">No modificar</option>
                <option v-for="u in unidades" :key="u.num_unidad" :value="u.num_unidad">
                  {{ u.nombre_unidad }}
                </option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">Nuevo Tipo de Aseo</label>
              <select class="municipal-form-control" v-model="actualizaciones.tipoAseo">
                <option value="">No modificar</option>
                <option value="D">Doméstico</option>
                <option value="C">Comercial</option>
                <option value="I">Industrial</option>
                <option value="S">Servicios</option>
              </select>
            </div>
          </div>

          <div class="row mb-3">
            <div class="col-md-12">
              <h6 class="border-bottom pb-2">Ajustes de Cuota</h6>
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">Tipo de Ajuste</label>
              <select class="municipal-form-control" v-model="actualizaciones.tipoAjusteCuota">
                <option value="">No ajustar cuota</option>
                <option value="FIJA">Cuota fija</option>
                <option value="PORCENTAJE">Porcentaje de incremento</option>
                <option value="MONTO">Incremento por monto</option>
              </select>
            </div>
            <div class="col-md-3" v-if="actualizaciones.tipoAjusteCuota === 'FIJA'">
              <label class="municipal-form-label">Nueva Cuota Mensual</label>
              <input type="number" class="municipal-form-control" v-model.number="actualizaciones.cuotaFija"
                step="0.01" min="0" placeholder="0.00" />
            </div>
            <div class="col-md-3" v-if="actualizaciones.tipoAjusteCuota === 'PORCENTAJE'">
              <label class="municipal-form-label">Porcentaje de Incremento (%)</label>
              <input type="number" class="municipal-form-control" v-model.number="actualizaciones.porcentajeIncremento"
                step="0.01" min="0" max="100" placeholder="0.00" />
            </div>
            <div class="col-md-3" v-if="actualizaciones.tipoAjusteCuota === 'MONTO'">
              <label class="municipal-form-label">Monto a Incrementar</label>
              <input type="number" class="municipal-form-control" v-model.number="actualizaciones.montoIncremento"
                step="0.01" min="0" placeholder="0.00" />
            </div>
          </div>

          <div class="row mb-3">
            <div class="col-md-12">
              <h6 class="border-bottom pb-2">Información Adicional</h6>
            </div>
            <div class="col-md-6">
              <label class="municipal-form-label">Motivo de la Actualización *</label>
              <input type="text" class="municipal-form-control" v-model="actualizaciones.motivo"
                placeholder="Ej: Reorganización de zonas y ajuste de tarifas 2024" />
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">Fecha de Aplicación *</label>
              <input type="date" class="municipal-form-control" v-model="actualizaciones.fechaAplicacion" />
            </div>
          </div>

          <div v-if="previsualizacion" class="alert alert-info">
            <h6><font-awesome-icon icon="eye" /> Previsualización de Cambios:</h6>
            <ul class="mb-0">
              <li v-if="actualizaciones.empresa">Empresa cambiará a: <strong>{{ obtenerNombreEmpresa(actualizaciones.empresa) }}</strong></li>
              <li v-if="actualizaciones.zona">Zona cambiará a: <strong>{{ actualizaciones.zona }}</strong></li>
              <li v-if="actualizaciones.unidad">Unidad cambiará a: <strong>{{ obtenerNombreUnidad(actualizaciones.unidad) }}</strong></li>
              <li v-if="actualizaciones.tipoAseo">Tipo de aseo cambiará a: <strong>{{ formatTipoAseoCompleto(actualizaciones.tipoAseo) }}</strong></li>
              <li v-if="actualizaciones.tipoAjusteCuota === 'FIJA'">Cuota se establecerá en: <strong>${{ formatCurrency(actualizaciones.cuotaFija) }}</strong></li>
              <li v-if="actualizaciones.tipoAjusteCuota === 'PORCENTAJE'">Cuota se incrementará en: <strong>{{ actualizaciones.porcentajeIncremento }}%</strong></li>
              <li v-if="actualizaciones.tipoAjusteCuota === 'MONTO'">Cuota se incrementará en: <strong>${{ formatCurrency(actualizaciones.montoIncremento) }}</strong></li>
            </ul>
          </div>

          <div class="d-flex justify-content-between">
            <button class="btn-municipal-secondary" @click="cancelar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <div>
              <button class="btn-municipal-info me-2" @click="previsualizacion = !previsualizacion">
                <font-awesome-icon icon="eye" /> {{ previsualizacion ? 'Ocultar' : 'Ver' }} Previsualización
              </button>
              <button class="btn-municipal-info" @click="aplicarActualizaciones"
                :disabled="!validarActualizacion()">
                <font-awesome-icon icon="save" /> Aplicar Actualizaciones
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Actualización General de Contratos">
      <h6>Descripción</h6>
      <p>Permite realizar modificaciones masivas en múltiples contratos simultáneamente.</p>
      <h6>Campos que se Pueden Actualizar</h6>
      <ul>
        <li>Empresa prestadora del servicio</li>
        <li>Zona de recolección</li>
        <li>Unidad recolectora asignada</li>
        <li>Tipo de aseo (Doméstico, Comercial, Industrial, Servicios)</li>
        <li>Cuota mensual (fija, por porcentaje o por monto)</li>
      </ul>
      <h6>Tipos de Ajuste de Cuota</h6>
      <ul>
        <li><strong>Fija:</strong> Establece la misma cuota para todos los contratos seleccionados</li>
        <li><strong>Porcentaje:</strong> Incrementa la cuota actual por un porcentaje</li>
        <li><strong>Monto:</strong> Incrementa la cuota actual por un monto fijo</li>
      </ul>
      <h6>Importante</h6>
      <p>Solo se modificarán los campos que tengan valor asignado. Los campos vacíos no se actualizarán.</p>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { handleError } = useLicenciasErrorHandler()
const { showToast } = useToast()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const contratos = ref([])
const zonas = ref([])
const empresas = ref([])
const unidades = ref([])
const contratosSeleccionados = ref([])
const seleccionarTodo = ref(false)
const previsualizacion = ref(false)

const filtros = ref({
  zona: '',
  tipoAseo: '',
  empresa: '',
  contratoDesde: '',
  contratoHasta: ''
})

const actualizaciones = ref({
  empresa: '',
  zona: '',
  unidad: '',
  tipoAseo: '',
  tipoAjusteCuota: '',
  cuotaFija: 0,
  porcentajeIncremento: 0,
  montoIncremento: 0,
  motivo: '',
  fechaAplicacion: new Date().toISOString().split('T')[0]
})

const buscarContratos = async () => {
  cargando.value = true
  try {
    const params = {
      p_zona: filtros.value.zona || null,
      p_tipo_aseo: filtros.value.tipoAseo || null,
      p_empresa: filtros.value.empresa || null,
      p_contrato_desde: filtros.value.contratoDesde || null,
      p_contrato_hasta: filtros.value.contratoHasta || null
    }
    const response = await execute('SP_ASEO_CONTRATOS_PARA_ACTUALIZAR', 'aseo_contratado', params)
    contratos.value = response || []
    contratosSeleccionados.value = []
    showToast(`${contratos.value.length} contrato(s) encontrado(s)`, 'success')
  } catch (error) {
    handleError(error, 'Error al buscar contratos')
  } finally {
    cargando.value = false
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

const validarActualizacion = () => {
  if (contratosSeleccionados.value.length === 0) return false
  if (!actualizaciones.value.motivo.trim()) return false
  if (!actualizaciones.value.fechaAplicacion) return false

  const tieneAlgunCambio = actualizaciones.value.empresa ||
                          actualizaciones.value.zona ||
                          actualizaciones.value.unidad ||
                          actualizaciones.value.tipoAseo ||
                          actualizaciones.value.tipoAjusteCuota

  return tieneAlgunCambio
}

const obtenerNombreEmpresa = (numEmpresa) => {
  const emp = empresas.value.find(e => e.num_empresa === numEmpresa)
  return emp ? emp.nombre_empresa : ''
}

const obtenerNombreUnidad = (numUnidad) => {
  const unidad = unidades.value.find(u => u.num_unidad === numUnidad)
  return unidad ? unidad.nombre_unidad : ''
}

const aplicarActualizaciones = async () => {
  const result = await Swal.fire({
    title: '¿Aplicar Actualizaciones?',
    html: `Se actualizarán <strong>${contratosSeleccionados.value.length}</strong> contrato(s).<br>
           Esta operación no se puede deshacer.`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#ffc107',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  cargando.value = true
  try {
    const params = {
      p_contratos: contratosSeleccionados.value.join(','),
      p_nueva_empresa: actualizaciones.value.empresa || null,
      p_nueva_zona: actualizaciones.value.zona || null,
      p_nueva_unidad: actualizaciones.value.unidad || null,
      p_nuevo_tipo_aseo: actualizaciones.value.tipoAseo || null,
      p_tipo_ajuste_cuota: actualizaciones.value.tipoAjusteCuota || null,
      p_cuota_fija: actualizaciones.value.cuotaFija || null,
      p_porcentaje_incremento: actualizaciones.value.porcentajeIncremento || null,
      p_monto_incremento: actualizaciones.value.montoIncremento || null,
      p_motivo: actualizaciones.value.motivo,
      p_fecha_aplicacion: actualizaciones.value.fechaAplicacion
    }

    await execute('SP_ASEO_APLICAR_ACTUALIZACIONES_MASIVAS', 'aseo_contratado', params)

    await Swal.fire('¡Actualizado!', 'Los contratos han sido actualizados correctamente', 'success')

    await buscarContratos()
    cancelar()
  } catch (error) {
    handleError(error, 'Error al aplicar actualizaciones')
  } finally {
    cargando.value = false
  }
}

const cancelar = () => {
  contratosSeleccionados.value = []
  seleccionarTodo.value = false
  previsualizacion.value = false
  actualizaciones.value = {
    empresa: '',
    zona: '',
    unidad: '',
    tipoAseo: '',
    tipoAjusteCuota: '',
    cuotaFija: 0,
    porcentajeIncremento: 0,
    montoIncremento: 0,
    motivo: '',
    fechaAplicacion: new Date().toISOString().split('T')[0]
  }
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Dom', 'C': 'Com', 'I': 'Ind', 'S': 'Ser' }
  return tipos[tipo] || tipo
}

const formatTipoAseoCompleto = (tipo) => {
  const tipos = { 'D': 'Doméstico', 'C': 'Comercial', 'I': 'Industrial', 'S': 'Servicios' }
  return tipos[tipo] || tipo
}

onMounted(async () => {
  try {
    const [respZonas, respEmpresas, respUnidades] = await Promise.all([
      execute('SP_ASEO_ZONAS_LIST', 'aseo_contratado', {}),
      execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {}),
      execute('SP_ASEO_UNIDADES_LIST', 'aseo_contratado', {})
    ])
    zonas.value = respZonas || []
    empresas.value = respEmpresas || []
    unidades.value = respUnidades || []
  } catch (error) {
    console.error('Error al cargar catálogos:', error)
  }
})
</script>
