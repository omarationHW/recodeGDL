<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-upload" />
      </div>
      <div class="module-view-info">
        <h1>Carga de Pagos Realizados en Mdo. Libertad</h1>
        <p>Mercados > Importación Masiva de Pagos desde Archivo de Texto</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Totales -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="chart-bar" />
            Totales de Transferencia
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-3">
              <div class="stat-box stat-success">
                <div class="stat-label">Pagos Grabados</div>
                <div class="stat-value">{{ formatNumber(stats.grabados) }}</div>
              </div>
            </div>

            <div class="col-md-3">
              <div class="stat-box stat-warning">
                <div class="stat-label">Pagos ya Grabados</div>
                <div class="stat-value">{{ formatNumber(stats.yaGrabados) }}</div>
              </div>
            </div>

            <div class="col-md-3">
              <div class="stat-box stat-danger">
                <div class="stat-label">Adeudos Borrados</div>
                <div class="stat-value">{{ formatNumber(stats.adeBorrados) }}</div>
              </div>
            </div>

            <div class="col-md-3">
              <div class="stat-box stat-info">
                <div class="stat-label">Total de Pagos</div>
                <div class="stat-value">{{ formatNumber(stats.total) }}</div>
              </div>
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-md-12">
              <div class="stat-box stat-primary">
                <div class="stat-label">Total Importe Pagado</div>
                <div class="stat-value">{{ formatCurrency(stats.importe) }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de pagos -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="table" />
            Registros del Archivo
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="pagos.length > 0">
              {{ formatNumber(pagos.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body">
          <!-- Botones de acción -->
          <div class="row mb-3">
            <div class="col-md-12">
              <div class="button-group-left">
                <button class="btn-municipal-primary" @click="abrirArchivo" :disabled="loading || procesando">
                  <font-awesome-icon icon="folder-open" />
                  Seleccionar Archivo
                </button>
                <button class="btn-municipal-primary" @click="procesarPagos" :disabled="loading || procesando || pagos.length === 0">
                  <font-awesome-icon :icon="procesando ? 'spinner' : 'upload'" :spin="procesando" />
                  {{ procesando ? 'Procesando...' : 'Actualizar Pagos' }}
                </button>
                <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading || procesando">
                  <font-awesome-icon icon="eraser" />
                  Limpiar
                </button>
              </div>
            </div>
          </div>

          <!-- Input file hidden -->
          <input
            ref="fileInput"
            type="file"
            accept=".txt"
            style="display: none"
            @change="onFileSelected"
          />

          <!-- Loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Leyendo archivo...</p>
          </div>

          <!-- Error -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Id Local</th>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Fecha Pago</th>
                  <th>Oficina</th>
                  <th>Caja</th>
                  <th>Operación</th>
                  <th class="text-end">Importe</th>
                  <th>Folio</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="pagos.length === 0">
                  <td colspan="11" class="text-center text-muted">
                    <font-awesome-icon icon="file-upload" size="2x" class="empty-icon" />
                    <p>Seleccione un archivo de texto (.txt) para cargar los pagos</p>
                  </td>
                </tr>
                <tr v-else v-for="(pago, index) in paginatedPagos" :key="index" class="row-hover">
                  <td>{{ pago.numero }}</td>
                  <td>{{ pago.id_local }}</td>
                  <td>{{ pago.axo }}</td>
                  <td>{{ pago.periodo }}</td>
                  <td>{{ pago.fecha_pago }}</td>
                  <td>{{ pago.oficina_pago }}</td>
                  <td>{{ pago.caja_pago }}</td>
                  <td>{{ pago.operacion_pago }}</td>
                  <td class="text-end">{{ formatCurrency(pago.importe_pago) }}</td>
                  <td>{{ pago.folio }}</td>
                  <td>
                    <span v-if="pago.estado === 'pendiente'" class="badge-secondary">
                      <font-awesome-icon icon="clock" /> Pendiente
                    </span>
                    <span v-else-if="pago.estado === 'procesando'" class="badge-info">
                      <font-awesome-icon icon="spinner" spin /> Procesando
                    </span>
                    <span v-else-if="pago.estado === 'grabado'" class="badge-success">
                      <font-awesome-icon icon="check" /> Grabado
                    </span>
                    <span v-else-if="pago.estado === 'existe'" class="badge-warning">
                      <font-awesome-icon icon="exclamation-triangle" /> Ya existe
                    </span>
                    <span v-else-if="pago.estado === 'error'" class="badge-danger">
                      <font-awesome-icon icon="times" /> Error
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="pagos.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ paginationStart + 1 }} - {{ Math.min(paginationEnd, pagos.length) }} de {{ pagos.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                @click="currentPage--"
                :disabled="currentPage === 0"
              >
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span class="pagination-page">Página {{ currentPage + 1 }} de {{ totalPages }}</span>
              <button
                class="btn-pagination"
                @click="currentPage++"
                :disabled="currentPage === totalPages - 1"
              >
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';

const { showLoading, hideLoading } = useGlobalLoading();
const { showToast } = useToast();

// Estado
const fileInput = ref(null);
const pagos = ref([]);
const loading = ref(false);
const procesando = ref(false);
const error = ref('');

// Estadísticas
const stats = ref({
  grabados: 0,
  yaGrabados: 0,
  adeBorrados: 0,
  total: 0,
  importe: 0
});

// Paginación
const currentPage = ref(0);
const pageSize = ref(50);

// Computed
const totalPages = computed(() => Math.ceil(pagos.value.length / pageSize.value));
const paginationStart = computed(() => currentPage.value * pageSize.value);
const paginationEnd = computed(() => paginationStart.value + pageSize.value);

const paginatedPagos = computed(() => {
  return pagos.value.slice(paginationStart.value, paginationEnd.value);
});

// Métodos
const mostrarAyuda = () => {
  showToast('Seleccione un archivo .txt con el formato correcto de pagos, luego presione "Actualizar Pagos" para procesar la carga masiva.', 'info');
};

const formatCurrency = (value) => {
  if (!value) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const formatNumber = (value) => {
  return new Intl.NumberFormat('es-MX').format(value);
};

const abrirArchivo = () => {
  if (fileInput.value) {
    fileInput.value.click();
  }
};

const limpiar = () => {
  pagos.value = [];
  stats.value = {
    grabados: 0,
    yaGrabados: 0,
    adeBorrados: 0,
    total: 0,
    importe: 0
  };
  currentPage.value = 0;
  error.value = '';
  showToast('Datos limpiados', 'info');
};

const onFileSelected = async (event) => {
  const file = event.target.files[0];
  if (!file) return;

  loading.value = true;
  error.value = '';
  pagos.value = [];

  showLoading('Leyendo archivo de texto', 'Por favor espere');
  try {
    const text = await file.text();
    const lines = text.split('\n').filter(line => line.trim());

    const parsed = [];
    let numero = 1;

    for (const line of lines) {
      if (line.trim().length < 70) continue;

      try {
        const pago = {
          numero: numero++,
          id_local: line.substring(0, 6).trim(),
          axo: line.substring(6, 10).trim(),
          periodo: line.substring(10, 12).trim(),
          fecha_pago: line.substring(12, 14).trim() + '/' +
                       line.substring(14, 16).trim() + '/' +
                       line.substring(16, 20).trim(),
          oficina_pago: line.substring(20, 23).trim(),
          caja_pago: line.substring(23, 24).trim(),
          operacion_pago: line.substring(24, 29).trim(),
          importe_pago: parseFloat(line.substring(29, 38).trim()) || 0,
          folio: line.substring(38, 44).trim(),
          fecha_actualizacion: line.substring(44, 63).trim(),
          id_usuario: line.substring(63, 66).trim(),
          rec: line.substring(66, 69).trim(),
          merc: line.substring(69, 72).trim(),
          estado: 'pendiente'
        };
        parsed.push(pago);
      } catch (e) {
        console.error('Error parseando línea:', e);
      }
    }

    pagos.value = parsed;

    if (parsed.length > 0) {
      showToast(`${parsed.length} registros cargados desde el archivo`, 'success');
    } else {
      showToast('No se encontraron registros válidos en el archivo', 'warning');
    }
  } catch (err) {
    error.value = 'Error al leer el archivo: ' + err.message;
    showToast(error.value, 'error');
  } finally {
    loading.value = false;
    hideLoading();
    // Reset file input
    if (fileInput.value) {
      fileInput.value.value = '';
    }
  }
};

const procesarPagos = async () => {
  if (pagos.value.length === 0) {
    showToast('No hay pagos para procesar', 'warning');
    return;
  }

  procesando.value = true;
  stats.value = {
    grabados: 0,
    yaGrabados: 0,
    adeBorrados: 0,
    total: 0,
    importe: 0
  };

  let grabados = 0;
  let yaGrabados = 0;
  let adeBorrados = 0;
  let importeTotal = 0;

  showLoading('Procesando pagos masivos', 'Por favor espere');
  try {
    for (let i = 0; i < pagos.value.length; i++) {
      const pago = pagos.value[i];
      pago.estado = 'procesando';

      try {
        const parametros = [
          { nombre: 'p_id_local', valor: parseInt(pago.id_local), tipo: 'integer' },
          { nombre: 'p_axo', valor: parseInt(pago.axo), tipo: 'integer' },
          { nombre: 'p_periodo', valor: parseInt(pago.periodo), tipo: 'integer' },
          { nombre: 'p_fecha_pago', valor: pago.fecha_pago, tipo: 'string' },
          { nombre: 'p_oficina_pago', valor: parseInt(pago.oficina_pago), tipo: 'integer' },
          { nombre: 'p_caja_pago', valor: pago.caja_pago, tipo: 'string' },
          { nombre: 'p_operacion_pago', valor: parseInt(pago.operacion_pago), tipo: 'integer' },
          { nombre: 'p_importe_pago', valor: pago.importe_pago, tipo: 'numeric' },
          { nombre: 'p_folio', valor: pago.folio, tipo: 'string' },
          { nombre: 'p_fecha_actualizacion', valor: pago.fecha_actualizacion, tipo: 'string' },
          { nombre: 'p_id_usuario', valor: parseInt(pago.id_usuario), tipo: 'integer' },
          { nombre: 'p_rec', valor: pago.rec, tipo: 'string' },
          { nombre: 'p_merc', valor: pago.merc, tipo: 'string' },
          { nombre: 'p_id_usuario_sistema', valor: 1, tipo: 'integer' }
        ];

        const res = await axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_importar_pago_texto',
            Base: 'padron_licencias',
            Parametros: parametros
          }
        });

        if (res.data.eResponse.success) {
          const result = res.data.eResponse.data.result[0];

          if (result.grabado) {
            pago.estado = 'grabado';
            grabados++;
            importeTotal += pago.importe_pago;
            if (result.adeudo_borrado) {
              adeBorrados++;
            }
          } else {
            pago.estado = 'existe';
            yaGrabados++;
            importeTotal += pago.importe_pago;
          }
        } else {
          pago.estado = 'error';
        }
      } catch (err) {
        console.error('Error procesando pago:', err);
        pago.estado = 'error';
      }
    }

    stats.value = {
      grabados,
      yaGrabados,
      adeBorrados,
      total: grabados + yaGrabados,
      importe: importeTotal
    };

    showToast(`Proceso completado: ${grabados} grabados, ${yaGrabados} ya existían, ${adeBorrados} adeudos borrados`, 'success');
  } finally {
    procesando.value = false;
    hideLoading();
  }
};

// Lifecycle
onMounted(() => {
  // Inicialización si es necesaria
});
</script>
