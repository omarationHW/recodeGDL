<template>
  <div class="module-view">
    <div class="module-view-header">
      <div>
        <h4 >
          <font-awesome-icon icon="file-contract" class="me-2 text-primary" />
          Administración de Contratos
        </h4>
        <p >Alta, Baja y Modificación de Contratos de Aseo</p>
      </div>
      <div>
        <button class="btn-municipal-secondary btn-sm me-2" @click="mostrarAyuda = true">
          <font-awesome-icon icon="circle-question" />
        </button>
        <button class="btn-municipal-primary btn-sm" @click="nuevoContrato">
          <font-awesome-icon icon="plus" /> Nuevo Contrato
        </button>
      </div>
    </div>

    <!-- Barra de búsqueda -->
    <div class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header">
        <h5>Búsqueda y Filtros</h5>
      </div>
<div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <input type="text" class="municipal-form-control" v-model="busqueda"
              placeholder="Buscar por contrato, cuenta o contribuyente..." @input="filtrar" />
          </div>
          <div class="col-md-2">
            <select class="municipal-form-control" v-model="filtroZona" @change="filtrar">
              <option value="">Todas las zonas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }}
              </option>
            </select>
          </div>
          <div class="col-md-2">
            <select class="municipal-form-control" v-model="filtroTipo" @change="filtrar">
              <option value="">Todos los tipos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-2">
            <select class="municipal-form-control" v-model="filtroStatus" @change="filtrar">
              <option value="">Todos</option>
              <option value="A">Activos</option>
              <option value="I">Cancelados</option>
            </select>
          </div>
          <div class="col-md-3">
            <button class="btn-municipal-secondary w-100" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" /> Limpiar Filtros
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Listado de contratos -->
    <div class="municipal-card">
      <div class="municipal-card-header bg-light d-flex justify-content-between align-items-center">
        <h6 class="mb-0">
          Contratos
          <span class="badge bg-primary ms-2">{{ contratosFiltrados.length }}</span>
        </h6>
        <div>
          <button class="btn btn-sm btn-success" @click="exportar">
            <font-awesome-icon icon="file-excel" /> Exportar
          </button>
        </div>
      </div>
      <div class="municipal-card-body p-0">
        <div class="table-responsive">
          <table class="municipal-table-hover table-sm mb-0">
            <thead>
              <tr>
                <th>Contrato</th>
                <th>Cuenta</th>
                <th>Contribuyente</th>
                <th>Domicilio</th>
                <th>Zona</th>
                <th>Tipo</th>
                <th class="text-end">Cuota</th>
                <th>Status</th>
                <th class="text-center">Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="contrato in paginados" :key="contrato.control_contrato">
                <td><strong>{{ contrato.num_contrato }}</strong></td>
                <td>{{ contrato.cuenta_catastral }}</td>
                <td>{{ contrato.contribuyente }}</td>
                <td>{{ contrato.domicilio_corto }}</td>
                <td class="text-center">{{ contrato.zona }}</td>
                <td class="text-center">
                  <span class="badge" :class="getBadgeTipo(contrato.tipo_aseo)">
                    {{ formatTipoAseo(contrato.tipo_aseo) }}
                  </span>
                </td>
                <td class="text-end">${{ formatCurrency(contrato.cuota_mensual) }}</td>
                <td class="text-center">
                  <span class="badge" :class="contrato.status === 'A' ? 'bg-success' : 'bg-secondary'">
                    {{ contrato.status === 'A' ? 'Activo' : 'Cancelado' }}
                  </span>
                </td>
                <td class="text-center">
                  <div class="btn-group btn-group-sm">
                    <button class="btn-municipal-primary" @click="verDetalle(contrato)" title="Ver detalle">
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button class="btn-municipal-info" @click="editarContrato(contrato)"
                      :disabled="contrato.status === 'I'" title="Editar">
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button class="btn-municipal-secondary" @click="cancelarContrato(contrato)"
                      :disabled="contrato.status === 'I'" title="Cancelar">
                      <font-awesome-icon icon="ban" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div v-if="totalPaginas > 1" class="municipal-card-footer">
        <nav>
          <ul class="pagination pagination-sm mb-0 justify-content-center">
            <li class="page-item" :class="{ disabled: paginaActual === 1 }">
              <a class="page-link" @click.prevent="cambiarPagina(paginaActual - 1)">Anterior</a>
            </li>
            <li v-for="p in paginasVisibles" :key="p" class="page-item" :class="{ active: p === paginaActual }">
              <a class="page-link" @click.prevent="cambiarPagina(p)">{{ p }}</a>
            </li>
            <li class="page-item" :class="{ disabled: paginaActual === totalPaginas }">
              <a class="page-link" @click.prevent="cambiarPagina(paginaActual + 1)">Siguiente</a>
            </li>
          </ul>
        </nav>
      </div>
    </div>

    <!-- Modal Formulario ABM -->
    <div v-if="mostrarModal" class="modal fade show d-block" tabindex="-1" style="background: rgba(0,0,0,0.5);">
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header" :class="modoEdicion === 'nuevo' ? 'bg-success text-white' : 'bg-warning text-dark'">
            <h5 class="modal-title">
              <font-awesome-icon :icon="modoEdicion === 'nuevo' ? 'plus' : 'edit'" class="me-2" />
              {{ modoEdicion === 'nuevo' ? 'Nuevo Contrato' : 'Editar Contrato #' + formulario.num_contrato }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <ul class="nav nav-tabs mb-3">
              <li class="municipal-tab-item">
                <a class="municipal-tab-link" :class="{ active: tabActiva === 'general' }"
                  @click.prevent="tabActiva = 'general'" href="#">General</a>
              </li>
              <li class="municipal-tab-item">
                <a class="municipal-tab-link" :class="{ active: tabActiva === 'servicio' }"
                  @click.prevent="tabActiva = 'servicio'" href="#">Servicio</a>
              </li>
              <li class="municipal-tab-item">
                <a class="municipal-tab-link" :class="{ active: tabActiva === 'domicilio' }"
                  @click.prevent="tabActiva = 'domicilio'" href="#">Domicilio</a>
              </li>
              <li class="municipal-tab-item">
                <a class="municipal-tab-link" :class="{ active: tabActiva === 'adicional' }"
                  @click.prevent="tabActiva = 'adicional'" href="#">Adicional</a>
              </li>
            </ul>

            <!-- Tab General -->
            <div v-show="tabActiva === 'general'">
              <div class="row mb-3">
                <div class="col-md-4">
                  <label class="municipal-form-label">Cuenta Catastral *</label>
                  <input type="text" class="municipal-form-control" v-model="formulario.cuenta_catastral"
                    maxlength="12" :disabled="modoEdicion === 'editar'" />
                </div>
                <div class="col-md-8">
                  <label class="municipal-form-label">Nombre del Contribuyente *</label>
                  <input type="text" class="municipal-form-control" v-model="formulario.contribuyente" />
                </div>
              </div>
              <div class="row mb-3">
                <div class="col-md-4">
                  <label class="municipal-form-label">RFC</label>
                  <input type="text" class="municipal-form-control" v-model="formulario.rfc"
                    maxlength="13" style="text-transform: uppercase;" />
                </div>
                <div class="col-md-4">
                  <label class="municipal-form-label">CURP</label>
                  <input type="text" class="municipal-form-control" v-model="formulario.curp"
                    maxlength="18" style="text-transform: uppercase;" />
                </div>
                <div class="col-md-4">
                  <label class="municipal-form-label">Teléfono</label>
                  <input type="text" class="municipal-form-control" v-model="formulario.telefono" />
                </div>
              </div>
              <div class="row mb-3">
                <div class="col-md-6">
                  <label class="municipal-form-label">Email</label>
                  <input type="email" class="municipal-form-control" v-model="formulario.email" />
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Fecha de Alta *</label>
                  <input type="date" class="municipal-form-control" v-model="formulario.fecha_alta" />
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Status</label>
                  <select class="municipal-form-control" v-model="formulario.status" :disabled="modoEdicion === 'nuevo'">
                    <option value="A">Activo</option>
                    <option value="I">Cancelado</option>
                  </select>
                </div>
              </div>
            </div>

            <!-- Tab Servicio -->
            <div v-show="tabActiva === 'servicio'">
              <div class="row mb-3">
                <div class="col-md-3">
                  <label class="municipal-form-label">Tipo de Aseo *</label>
                  <select class="municipal-form-control" v-model="formulario.tipo_aseo">
                    <option value="">Seleccione...</option>
                    <option value="D">Doméstico</option>
                    <option value="C">Comercial</option>
                    <option value="I">Industrial</option>
                    <option value="S">Servicios</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Empresa *</label>
                  <select class="municipal-form-control" v-model="formulario.num_empresa">
                    <option value="">Seleccione...</option>
                    <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                      {{ emp.nombre_empresa }}
                    </option>
                  </select>
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Unidad Recolectora</label>
                  <select class="municipal-form-control" v-model="formulario.num_unidad">
                    <option value="">Sin asignar</option>
                    <option v-for="u in unidades" :key="u.num_unidad" :value="u.num_unidad">
                      {{ u.nombre_unidad }}
                    </option>
                  </select>
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Periodo Inicial</label>
                  <input type="text" class="municipal-form-control" v-model="formulario.periodo_inicial"
                    placeholder="YYYYMM" maxlength="6" />
                </div>
              </div>
              <div class="row mb-3">
                <div class="col-md-3">
                  <label class="municipal-form-label">Cuota Mensual *</label>
                  <div class="input-group">
                    <span class="input-group-text">$</span>
                    <input type="number" class="municipal-form-control" v-model.number="formulario.cuota_mensual"
                      step="0.01" min="0" />
                  </div>
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Descuento (%)</label>
                  <input type="number" class="municipal-form-control" v-model.number="formulario.descuento"
                    step="0.01" min="0" max="100" />
                </div>
              </div>
            </div>

            <!-- Tab Domicilio -->
            <div v-show="tabActiva === 'domicilio'">
              <div class="row mb-3">
                <div class="col-md-6">
                  <label class="municipal-form-label">Calle</label>
                  <input type="text" class="municipal-form-control" v-model="formulario.calle" />
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Número Exterior</label>
                  <input type="text" class="municipal-form-control" v-model="formulario.num_exterior" />
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Número Interior</label>
                  <input type="text" class="municipal-form-control" v-model="formulario.num_interior" />
                </div>
              </div>
              <div class="row mb-3">
                <div class="col-md-4">
                  <label class="municipal-form-label">Colonia</label>
                  <input type="text" class="municipal-form-control" v-model="formulario.colonia" />
                </div>
                <div class="col-md-2">
                  <label class="municipal-form-label">Zona *</label>
                  <select class="municipal-form-control" v-model="formulario.zona">
                    <option value="">Seleccione...</option>
                    <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                      Zona {{ z.zona }}
                    </option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Referencias</label>
                  <input type="text" class="municipal-form-control" v-model="formulario.referencias" />
                </div>
              </div>
            </div>

            <!-- Tab Adicional -->
            <div v-show="tabActiva === 'adicional'">
              <div class="row mb-3">
                <div class="col-md-12">
                  <label class="municipal-form-label">Observaciones</label>
                  <textarea class="municipal-form-control" v-model="formulario.observaciones" rows="4"></textarea>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cerrarModal">Cancelar</button>
            <button type="button" class="btn-municipal-primary" @click="guardarContrato"
              :disabled="!validarFormulario()">
              <font-awesome-icon icon="save" /> Guardar
            </button>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Administración de Contratos">
      <h6>Descripción</h6>
      <p>Módulo principal para la gestión completa de contratos de aseo contratado (Alta, Baja, Modificación).</p>
      <h6>Operaciones</h6>
      <ul>
        <li><strong>Nuevo:</strong> Crear nuevo contrato</li>
        <li><strong>Editar:</strong> Modificar datos de contrato activo</li>
        <li><strong>Cancelar:</strong> Dar de baja un contrato</li>
        <li><strong>Ver:</strong> Consultar detalle completo</li>
      </ul>
      <h6>Datos Requeridos</h6>
      <ul>
        <li>Cuenta catastral (12 dígitos)</li>
        <li>Nombre del contribuyente</li>
        <li>Tipo de aseo</li>
        <li>Empresa prestadora</li>
        <li>Zona de servicio</li>
        <li>Cuota mensual</li>
      </ul>
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
const mostrarModal = ref(false)
const modoEdicion = ref('nuevo')
const tabActiva = ref('general')
const contratos = ref([])
const zonas = ref([])
const empresas = ref([])
const unidades = ref([])
const busqueda = ref('')
const filtroZona = ref('')
const filtroTipo = ref('')
const filtroStatus = ref('A')
const paginaActual = ref(1)
const registrosPorPagina = 20

const formulario = ref({
  control_contrato: null,
  num_contrato: '',
  cuenta_catastral: '',
  contribuyente: '',
  rfc: '',
  curp: '',
  telefono: '',
  email: '',
  tipo_aseo: '',
  num_empresa: '',
  num_unidad: '',
  zona: '',
  colonia: '',
  calle: '',
  num_exterior: '',
  num_interior: '',
  referencias: '',
  cuota_mensual: 0,
  descuento: 0,
  periodo_inicial: '',
  fecha_alta: new Date().toISOString().split('T')[0],
  status: 'A',
  observaciones: ''
})

const contratosFiltrados = computed(() => {
  let resultado = contratos.value

  if (busqueda.value) {
    const busq = busqueda.value.toLowerCase()
    resultado = resultado.filter(c =>
      c.num_contrato?.toLowerCase().includes(busq) ||
      c.cuenta_catastral?.toLowerCase().includes(busq) ||
      c.contribuyente?.toLowerCase().includes(busq)
    )
  }

  if (filtroZona.value) {
    resultado = resultado.filter(c => c.zona === filtroZona.value)
  }

  if (filtroTipo.value) {
    resultado = resultado.filter(c => c.tipo_aseo === filtroTipo.value)
  }

  if (filtroStatus.value) {
    resultado = resultado.filter(c => c.status === filtroStatus.value)
  }

  return resultado
})

const totalPaginas = computed(() => {
  return Math.ceil(contratosFiltrados.value.length / registrosPorPagina)
})

const paginados = computed(() => {
  const inicio = (paginaActual.value - 1) * registrosPorPagina
  const fin = inicio + registrosPorPagina
  return contratosFiltrados.value.slice(inicio, fin)
})

const paginasVisibles = computed(() => {
  const maxVisible = 5
  let inicio = Math.max(1, paginaActual.value - Math.floor(maxVisible / 2))
  let fin = Math.min(totalPaginas.value, inicio + maxVisible - 1)

  if (fin - inicio < maxVisible - 1) {
    inicio = Math.max(1, fin - maxVisible + 1)
  }

  const paginas = []
  for (let i = inicio; i <= fin; i++) {
    paginas.push(i)
  }
  return paginas
})

const cargarContratos = async () => {
  cargando.value = true
  try {
    const response = await execute('SP_ASEO_CONTRATOS_LIST', 'aseo_contratado', {})
    contratos.value = response || []
  } catch (error) {
    handleError(error, 'Error al cargar contratos')
  } finally {
    cargando.value = false
  }
}

const nuevoContrato = () => {
  modoEdicion.value = 'nuevo'
  formulario.value = {
    control_contrato: null,
    num_contrato: '',
    cuenta_catastral: '',
    contribuyente: '',
    rfc: '',
    curp: '',
    telefono: '',
    email: '',
    tipo_aseo: '',
    num_empresa: '',
    num_unidad: '',
    zona: '',
    colonia: '',
    calle: '',
    num_exterior: '',
    num_interior: '',
    referencias: '',
    cuota_mensual: 0,
    descuento: 0,
    periodo_inicial: '',
    fecha_alta: new Date().toISOString().split('T')[0],
    status: 'A',
    observaciones: ''
  }
  tabActiva.value = 'general'
  mostrarModal.value = true
}

const editarContrato = (contrato) => {
  modoEdicion.value = 'editar'
  formulario.value = { ...contrato }
  tabActiva.value = 'general'
  mostrarModal.value = true
}

const verDetalle = (contrato) => {
  // Implementar vista de detalle si se requiere
  showToast('Vista de detalle (por implementar)', 'info')
}

const cancelarContrato = async (contrato) => {
  const result = await Swal.fire({
    title: '¿Cancelar Contrato?',
    html: `Se cancelará el contrato <strong>#${contrato.num_contrato}</strong><br>
           de <strong>${contrato.contribuyente}</strong>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar contrato',
    cancelButtonText: 'No'
  })

  if (!result.isConfirmed) return

  const { value: motivo } = await Swal.fire({
    title: 'Motivo de Cancelación',
    input: 'textarea',
    inputLabel: 'Ingrese el motivo',
    inputPlaceholder: 'Ej: Solicitud del cliente, cambio de domicilio...',
    inputAttributes: {
      'aria-label': 'Motivo de cancelación'
    },
    showCancelButton: true,
    confirmButtonText: 'Confirmar',
    cancelButtonText: 'Cancelar'
  })

  if (!motivo) return

  cargando.value = true
  try {
    const params = {
      p_control_contrato: contrato.control_contrato,
      p_motivo_cancelacion: motivo,
      p_fecha_cancelacion: new Date().toISOString().split('T')[0]
    }
    await execute('SP_ASEO_CANCELAR_CONTRATO', 'aseo_contratado', params)

    await Swal.fire('¡Cancelado!', 'El contrato ha sido cancelado correctamente', 'success')
    await cargarContratos()
  } catch (error) {
    handleError(error, 'Error al cancelar contrato')
  } finally {
    cargando.value = false
  }
}

const guardarContrato = async () => {
  if (!validarFormulario()) return

  const result = await Swal.fire({
    title: modoEdicion.value === 'nuevo' ? '¿Crear Contrato?' : '¿Guardar Cambios?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  cargando.value = true
  try {
    const sp = modoEdicion.value === 'nuevo' ? 'SP_ASEO_INSERTAR_CONTRATO' : 'SP_ASEO_ACTUALIZAR_CONTRATO'
    await execute(sp, 'aseo_contratado', formulario.value)

    await Swal.fire('¡Guardado!', 'El contrato ha sido guardado correctamente', 'success')
    cerrarModal()
    await cargarContratos()
  } catch (error) {
    handleError(error, 'Error al guardar contrato')
  } finally {
    cargando.value = false
  }
}

const validarFormulario = () => {
  if (!formulario.value.cuenta_catastral || formulario.value.cuenta_catastral.length !== 12) return false
  if (!formulario.value.contribuyente) return false
  if (!formulario.value.tipo_aseo) return false
  if (!formulario.value.num_empresa) return false
  if (!formulario.value.zona) return false
  if (!formulario.value.cuota_mensual || formulario.value.cuota_mensual <= 0) return false
  if (!formulario.value.fecha_alta) return false
  return true
}

const cerrarModal = () => {
  mostrarModal.value = false
}

const filtrar = () => {
  paginaActual.value = 1
}

const limpiarFiltros = () => {
  busqueda.value = ''
  filtroZona.value = ''
  filtroTipo.value = ''
  filtroStatus.value = 'A'
  paginaActual.value = 1
}

const cambiarPagina = (pagina) => {
  if (pagina >= 1 && pagina <= totalPaginas.value) {
    paginaActual.value = pagina
  }
}

const exportar = () => showToast('Exportando contratos...', 'info')

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Dom', 'C': 'Com', 'I': 'Ind', 'S': 'Ser' }
  return tipos[tipo] || tipo
}

const getBadgeTipo = (tipo) => {
  const colores = {
    'D': 'bg-success',
    'C': 'bg-primary',
    'I': 'bg-warning',
    'S': 'bg-info'
  }
  return colores[tipo] || 'bg-secondary'
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
    await cargarContratos()
  } catch (error) {
    console.error('Error al cargar datos iniciales:', error)
  }
})
</script>

