<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-bill" />
      </div>
      <div class="module-view-info">
        <h1>Pagos Diversos</h1>
        <p>Consulta de pagos diversos registrados</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>
    <div class="module-view-content">
      <!-- Card de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="pagar"
                placeholder="Ingrese número de cuenta"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="pagar">
              <font-awesome-icon icon="search" v-if="!loading" />
              <span v-if="loading">Buscando...</span>
              <span v-else>Buscar</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Card de resultados -->
      <div class="municipal-card" v-if="allRows.length > 0">
        <div class="municipal-card-header">
          <h5>Resultados ({{ allRows.length }} registros encontrados)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="col in cols" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td v-for="col in cols" :key="col">{{ row[col] }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} a {{ endIndex }} de {{ allRows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="pagination-button"
                :disabled="currentPage === 1"
                @click="goToPage(currentPage - 1)"
              >
                <font-awesome-icon icon="chevron-left" />
                Anterior
              </button>
              <div class="pagination-pages">
                <button
                  v-for="page in visiblePages"
                  :key="page"
                  class="pagination-button"
                  :class="{ active: page === currentPage }"
                  @click="goToPage(page)"
                >
                  {{ page }}
                </button>
              </div>
              <button
                class="pagination-button"
                :disabled="currentPage === totalPages"
                @click="goToPage(currentPage + 1)"
              >
                Siguiente
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Mensaje sin resultados -->
      <div class="municipal-card" v-else-if="searched && allRows.length === 0">
        <div class="municipal-card-body">
          <p class="text-center text-muted">
            <font-awesome-icon icon="search" size="3x" class="mb-3" />
            <br />
            No se encontraron registros con los criterios de búsqueda
          </p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'pagosdivfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Pagos Diversos'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'pagosdivfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Pagos Diversos'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue';
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { loading, execute } = useApi();
const { showLoading, hideLoading } = useGlobalLoading()
const BASE_DB = 'multas_reglamentos';
const OP = 'RECAUDADORA_PAGOSDIVFRM';
const SCHEMA = 'publico';

const filters = ref({
  cuenta: ''
});

const allRows = ref([]);
const cols = ref([]);
const searched = ref(false);
const currentPage = ref(1);
const pageSize = 10;

// Paginación computed
const totalPages = computed(() => Math.ceil(allRows.value.length / pageSize));

const startIndex = computed(() => (currentPage.value - 1) * pageSize);
const endIndex = computed(() => Math.min(currentPage.value * pageSize, allRows.value.length));

const paginatedRows = computed(() => {
  return allRows.value.slice(startIndex.value, endIndex.value);
});

const visiblePages = computed(() => {
  const pages = [];
  const maxVisible = 5;
  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2));
  let end = Math.min(totalPages.value, start + maxVisible - 1);

  if (end - start < maxVisible - 1) {
    start = Math.max(1, end - maxVisible + 1);
  }

  for (let i = start; i <= end; i++) {
    pages.push(i);
  }

  return pages;
});

async function pagar() {
  searched.value = false;
  currentPage.value = 1;
  allRows.value = [];
  cols.value = [];

  try {
    showLoading('Consultando...', 'Por favor espere')
    const data = await execute(OP, BASE_DB, [
      { name: 'clave_cuenta', type: 'C', value: String(filters.value.cuenta || '') }
    ], '', null, SCHEMA);

    // Extraer los datos de la respuesta
    let rows = [];
    if (data?.result) {
      rows = data.result;
    } else if (data?.rows) {
      rows = data.rows;
    } else if (Array.isArray(data)) {
      rows = data;
    }

    allRows.value = rows;
    cols.value = rows.length > 0 ? Object.keys(rows[0]) : [];
    searched.value = true;
  } catch (e) {
    console.error('Error al buscar pagos diversos:', e);
    allRows.value = [];
    cols.value = [];
    searched.value = true;
  } finally {
    hideLoading()
  }
}

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
  }
}
</script>

