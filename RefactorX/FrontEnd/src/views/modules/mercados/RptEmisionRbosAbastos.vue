<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="shopping-basket" />
      </div>
      <div class="module-view-info">
        <h1>Emisión de Recibos de Abastos</h1>
        <p>Inicio > Mercados > Emisión Abastos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="buscar">
          <font-awesome-icon icon="search" /> Buscar
        </button>
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="results.length === 0">
          <font-awesome-icon icon="file-excel" /> Exportar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select v-model="filters.oficina" class="municipal-form-control" @change="onOficinaChange">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_recaudadora" :value="rec.id_recaudadora">
                  {{ rec.id_recaudadora }} - {{ rec.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select v-model="filters.mercado" class="municipal-form-control" :disabled="!mercados.length">
                <option value="">Seleccione...</option>
                <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
                  {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" v-model.number="filters.axo" class="municipal-form-control"
                     min="1990" :max="new Date().getFullYear() + 1" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo (Mes) <span class="required">*</span></label>
              <select v-model.number="filters.periodo" class="municipal-form-control">
                <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <div v-if="results.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Recibos de Abastos</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} locales</span>
            <span class="badge-success ms-2">Total: {{ formatCurrency(totalSubtotal) }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Datos Local</th>
                  <th>Nombre</th>
                  <th>Descripción</th>
                  <th>Meses</th>
                  <th class="text-end">Renta</th>
                  <th class="text-end">Adeudo</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Subtotal</th>
                  <th class="text-end">Multa</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in paginatedResults" :key="row.id_local" class="row-hover">
                  <td>{{ datosLocal(row) }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-center">{{ row.meses || 'N/A' }}</td>
                  <td class="text-end">{{ formatCurrency(row.renta) }}</td>
                  <td class="text-end">{{ formatCurrency(row.adeudo) }}</td>
                  <td class="text-end">{{ formatCurrency(row.recargos) }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(row.subtotal) }}</strong></td>
                  <td class="text-end">{{ formatCurrency(row.multa) }}</td>
                  <td class="text-center">
                    <button class="btn-municipal-secondary btn-sm" @click="verRequerimientos(row.id_local)">
                      <font-awesome-icon icon="file-alt" /> Ver
                    </button>
                  </td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="5" class="text-end"><strong>TOTALES:</strong></td>
                  <td class="text-end"><strong class="text-primary">{{ formatCurrency(totalAdeudo) }}</strong></td>
                  <td class="text-end"><strong class="text-warning">{{ formatCurrency(totalRecargos) }}</strong></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(totalSubtotal) }}</strong></td>
                  <td class="text-end"><strong class="text-danger">{{ formatCurrency(totalMulta) }}</strong></td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container">
            <div class="pagination-info">
              <label>Mostrar:</label>
              <select v-model.number="pageSize" class="municipal-form-control pagination-select">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
                <option :value="250">250</option>
              </select>
              <span>registros por página</span>
            </div>
            <div class="pagination-controls">
              <button class="btn-municipal-secondary btn-sm" @click="currentPage--" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span>
              <button class="btn-municipal-secondary btn-sm" @click="currentPage++" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="!results.length && busquedaRealizada" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No se encontraron datos con los filtros seleccionados.
      </div>
    </div>

    <!-- Modal Requerimientos -->
    <Modal
      v-if="modalRequerimientos.show"
      :title="`Requerimientos del Local #${modalRequerimientos.localId}`"
      size="lg"
      @close="modalRequerimientos.show = false"
    >
        <div v-if="modalRequerimientos.loading" class="text-center py-3">
          <div class="spinner-border municipal-text-primary" role="status"></div>
          <p>Cargando requerimientos...</p>
        </div>
        <div v-else-if="modalRequerimientos.data.length">
          <table class="municipal-table table-sm">
            <thead class="municipal-table-header">
              <tr>
                <th>Folio</th>
                <th>Diligencia</th>
                <th class="text-end">Importe Multa</th>
                <th class="text-end">Importe Gastos</th>
                <th>Fecha Emisión</th>
                <th>Observaciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="req in modalRequerimientos.data" :key="req.folio">
                <td>{{ req.folio }}</td>
                <td>{{ req.diligencia }}</td>
                <td class="text-end">{{ formatCurrency(req.importe_multa) }}</td>
                <td class="text-end">{{ formatCurrency(req.importe_gastos) }}</td>
                <td>{{ req.fecha_emision }}</td>
                <td>{{ req.observaciones }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else class="municipal-alert municipal-alert-info">
          <font-awesome-icon icon="info-circle" /> No hay requerimientos para este local.
        </div>

      <template #footer>
        <button class="btn-municipal-secondary" @click="modalRequerimientos.show = false">
          Cerrar
        </button>
      </template>
    </Modal>

    <!-- Modal Ayuda -->
    <Modal
      v-if="modalAyuda.show"
      title="Ayuda - Emisión de Recibos de Abastos"
      @close="modalAyuda.show = false"
    >
        <div class="municipal-alert municipal-alert-info">
          <font-awesome-icon icon="info-circle" class="me-2" />
          <strong>Emisión de Recibos de Abastos</strong>
        </div>
        <div class="mt-3">
          <h6><font-awesome-icon icon="search" class="me-2" />Búsqueda de Recibos</h6>
          <p>Seleccione la recaudadora, mercado, año y periodo para generar el reporte de emisión de recibos de abastos.</p>

          <h6 class="mt-3"><font-awesome-icon icon="filter" class="me-2" />Filtros Disponibles</h6>
          <ul>
            <li><strong>Recaudadora:</strong> Seleccione la oficina recaudadora correspondiente.</li>
            <li><strong>Mercado:</strong> Seleccione el mercado específico (se carga según la recaudadora).</li>
            <li><strong>Año:</strong> Ingrese el año del periodo a consultar.</li>
            <li><strong>Periodo (Mes):</strong> Seleccione el mes del periodo a consultar.</li>
          </ul>

          <h6 class="mt-3"><font-awesome-icon icon="list-alt" class="me-2" />Información Mostrada</h6>
          <ul>
            <li>Datos completos del local (oficina-mercado-categoría-sección-local)</li>
            <li>Información del contribuyente y descripción del local</li>
            <li>Desglose financiero: Renta, Adeudo, Recargos, Subtotal y Multas</li>
            <li>Acceso a requerimientos asociados a cada local</li>
          </ul>

          <h6 class="mt-3"><font-awesome-icon icon="file-alt" class="me-2" />Requerimientos</h6>
          <p>Utilice el botón "Ver" en cada registro para consultar los requerimientos asociados al local, incluyendo folios, diligencias, importes de multas y gastos.</p>

          <h6 class="mt-3"><font-awesome-icon icon="file-excel" class="me-2" />Exportación</h6>
          <p>Use el botón "Exportar" para descargar los resultados en formato CSV con todos los datos mostrados en la tabla.</p>
        </div>

      <template #footer>
        <button class="btn-municipal-primary" @click="modalAyuda.show = false">
          Entendido
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import Modal from '@/components/common/Modal.vue';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';

const { showLoading, hideLoading } = useGlobalLoading();
const toast = useToast();

const filters = ref({
  oficina: '',
  mercado: '',
  axo: new Date().getFullYear(),
  periodo: new Date().getMonth() + 1
});

const recaudadoras = ref([]);
const mercados = ref([]);
const results = ref([]);
const busquedaRealizada = ref(false);
const currentPage = ref(1);
const pageSize = ref(25);

// Modal Requerimientos
const modalRequerimientos = ref({
  show: false,
  localId: null,
  data: [],
  loading: false
});

// Modal Ayuda
const modalAyuda = ref({
  show: false
});

const meses = ref([
  { value: 1, label: 'Enero' }, { value: 2, label: 'Febrero' }, { value: 3, label: 'Marzo' },
  { value: 4, label: 'Abril' }, { value: 5, label: 'Mayo' }, { value: 6, label: 'Junio' },
  { value: 7, label: 'Julio' }, { value: 8, label: 'Agosto' }, { value: 9, label: 'Septiembre' },
  { value: 10, label: 'Octubre' }, { value: 11, label: 'Noviembre' }, { value: 12, label: 'Diciembre' }
]);

const totalPages = computed(() => Math.ceil(results.value.length / pageSize.value) || 1);
const paginatedResults = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  return results.value.slice(start, start + pageSize.value);
});

const totalAdeudo = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.adeudo) || 0), 0));
const totalRecargos = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.recargos) || 0), 0));
const totalSubtotal = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.subtotal) || 0), 0));
const totalMulta = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.multa) || 0), 0));

const fetchRecaudadoras = async () => {
  showLoading('Cargando Reporte de Emisión de Recibos Abastos', 'Preparando oficinas recaudadoras...');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'mercados',
        Parametros: []
      }
    });
    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      recaudadoras.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error);
    toast.show('Error al cargar las recaudadoras', 'danger');
  } finally {
    hideLoading();
  }
};

const onOficinaChange = async () => {
  filters.value.mercado = '';
  mercados.value = [];
  if (!filters.value.oficina) return;

  showLoading('Cargando mercados...', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_mercados_by_recaudadora',
        Base: 'mercados',
        Parametros: [{ Nombre: 'p_id_rec', Valor: parseInt(filters.value.oficina) }]
      }
    });
    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      mercados.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
    toast.show('Error al cargar los mercados', 'danger');
  } finally {
    hideLoading();
  }
};

const buscar = async () => {
  if (!filters.value.oficina || !filters.value.mercado) {
    toast.show('Por favor complete todos los filtros requeridos', 'warning');
    return;
  }

  busquedaRealizada.value = false;
  showLoading('Consultando emisión de recibos...', 'Por favor espere');

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_rpt_emision_rbos_abastos',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) },
          { Nombre: 'p_mercado', Valor: parseInt(filters.value.mercado) },
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_periodo', Valor: parseInt(filters.value.periodo) }
        ]
      }
    });

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      results.value = response.data.eResponse.data.result;
      busquedaRealizada.value = true;
      currentPage.value = 1;

      if (results.value.length > 0) {
        toast.show(`Se encontraron ${results.value.length} registros`, 'success');
      }
    } else {
      results.value = [];
      busquedaRealizada.value = true;
    }
  } catch (error) {
    console.error('Error al consultar:', error);
    toast.show('Error al realizar la consulta', 'danger');
    results.value = [];
    busquedaRealizada.value = true;
  } finally {
    hideLoading();
  }
};

const verRequerimientos = async (id_local) => {
  modalRequerimientos.value = {
    show: true,
    localId: id_local,
    data: [],
    loading: true
  };

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_requerimientos_abastos',
        Base: 'mercados',
        Parametros: [{ Nombre: 'p_id_local', Valor: parseInt(id_local) }]
      }
    });

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      modalRequerimientos.value.data = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar requerimientos:', error);
    toast.show('Error al cargar los requerimientos', 'danger');
  } finally {
    modalRequerimientos.value.loading = false;
  }
};

const datosLocal = (row) => {
  return `${row.oficina}-${row.num_mercado}-${row.categoria}-${row.seccion}-${row.local}${row.letra_local || ''}${row.bloque ? '-' + row.bloque : ''}`;
};

const formatCurrency = (value) => {
  if (value == null) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const exportarExcel = () => {
  try {
    const csv = [
      'Datos Local,Nombre,Descripción,Meses,Renta,Adeudo,Recargos,Subtotal,Multa',
      ...results.value.map(r =>
        `${datosLocal(r)},${r.nombre},${r.descripcion},${r.meses},${r.renta},${r.adeudo},${r.recargos},${r.subtotal},${r.multa}`
      )
    ].join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `emision_abastos_${filters.value.axo}_${filters.value.periodo}.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
    toast.show('Archivo exportado correctamente', 'success');
  } catch (error) {
    console.error('Error al exportar:', error);
    toast.show('Error al exportar el archivo', 'danger');
  }
};

const mostrarAyuda = () => {
  modalAyuda.value.show = true;
};

onMounted(async () => {
  await fetchRecaudadoras();
});
</script>
