<template>
  <div class="grid-component">
    <!-- Toolbar superior -->
    <div class="grid-toolbar mb-3" v-if="showToolbar">
      <div class="row align-items-center">
        <div class="col-md-6">
          <div class="input-group">
            <span class="input-group-text">
              <i class="fas fa-search"></i>
            </span>
            <input
              v-model="searchQuery"
              type="text"
              class="form-control"
              placeholder="Buscar..."
              @input="filterData"
            />
          </div>
        </div>
        <div class="col-md-6 text-end">
          <div class="btn-group">
            <button
              v-for="action in toolbarActions"
              :key="action.name"
              :class="action.class || 'btn btn-primary'"
              @click="$emit(action.event)"
              :title="action.title"
            >
              <i v-if="action.icon" :class="action.icon"></i>
              {{ action.label }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla principal -->
    <div class="table-responsive">
      <table class="table table-bordered table-hover">
        <thead class="table-dark">
          <tr>
            <th v-if="selectable" class="text-center" style="width: 40px;">
              <input
                type="checkbox"
                :checked="allSelected"
                @change="toggleSelectAll"
                class="form-check-input"
              />
            </th>
            <th
              v-for="column in columns"
              :key="column.field"
              :style="{ width: column.width }"
              :class="[column.headerClass, { sortable: column.sortable }]"
              @click="column.sortable && sortBy(column.field)"
            >
              <div class="d-flex align-items-center justify-content-between">
                <span>{{ column.headerName }}</span>
                <div v-if="column.sortable" class="sort-indicators">
                  <i 
                    class="fas fa-sort"
                    :class="{
                      'fa-sort-up': sortField === column.field && sortOrder === 'asc',
                      'fa-sort-down': sortField === column.field && sortOrder === 'desc'
                    }"
                  ></i>
                </div>
              </div>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(row, index) in paginatedData"
            :key="row.id || index"
            :class="{ 'table-active': selectedRows.includes(row.id) }"
          >
            <td v-if="selectable" class="text-center">
              <input
                type="checkbox"
                :checked="selectedRows.includes(row.id)"
                @change="toggleRowSelection(row.id)"
                class="form-check-input"
              />
            </td>
            <td
              v-for="column in columns"
              :key="column.field"
              :class="column.cellClass"
            >
              <!-- Columna personalizada con slot -->
              <slot
                v-if="column.cellRenderer"
                :name="column.cellRenderer"
                :value="getNestedValue(row, column.field)"
                :row="row"
                :column="column"
              >
                {{ getNestedValue(row, column.field) }}
              </slot>
              
              <!-- Columna de acciones -->
              <div v-else-if="column.type === 'actions'" class="btn-group btn-group-sm">
                <button
                  v-for="action in column.actions"
                  :key="action.name"
                  :class="action.class || 'btn btn-outline-primary'"
                  @click="$emit(action.event, row)"
                  :title="action.title"
                  :disabled="action.disabled && action.disabled(row)"
                >
                  <i v-if="action.icon" :class="action.icon"></i>
                  {{ action.label }}
                </button>
              </div>
              
              <!-- Columna de estado con badges -->
              <span
                v-else-if="column.type === 'badge'"
                :class="getBadgeClass(getNestedValue(row, column.field))"
              >
                {{ getNestedValue(row, column.field) }}
              </span>
              
              <!-- Columna de fecha formateada -->
              <span v-else-if="column.type === 'date'">
                {{ formatDate(getNestedValue(row, column.field)) }}
              </span>
              
              <!-- Columna de moneda -->
              <span v-else-if="column.type === 'currency'">
                {{ formatCurrency(getNestedValue(row, column.field)) }}
              </span>
              
              <!-- Columna normal -->
              <span v-else>
                {{ getNestedValue(row, column.field) }}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Mensaje cuando no hay datos -->
    <div v-if="filteredData.length === 0" class="text-center py-5">
      <div class="text-muted">
        <i class="fas fa-inbox fa-3x mb-3"></i>
        <p class="mb-0">{{ noDataMessage }}</p>
      </div>
    </div>

    <!-- Paginación -->
    <nav v-if="pagination && totalPages > 1" class="d-flex justify-content-between align-items-center mt-3">
      <div class="text-muted">
        Mostrando {{ startRecord }} - {{ endRecord }} de {{ filteredData.length }} registros
      </div>
      <ul class="pagination pagination-sm mb-0">
        <li class="page-item" :class="{ disabled: currentPage === 1 }">
          <button class="page-link" @click="goToPage(currentPage - 1)">
            <i class="fas fa-chevron-left"></i>
          </button>
        </li>
        <li
          v-for="page in visiblePages"
          :key="page"
          class="page-item"
          :class="{ active: page === currentPage }"
        >
          <button class="page-link" @click="goToPage(page)">{{ page }}</button>
        </li>
        <li class="page-item" :class="{ disabled: currentPage === totalPages }">
          <button class="page-link" @click="goToPage(currentPage + 1)">
            <i class="fas fa-chevron-right"></i>
          </button>
        </li>
      </ul>
    </nav>
  </div>
</template>

<script>
export default {
  name: 'GridComponent',
  props: {
    rowData: {
      type: Array,
      default: () => []
    },
    columnDefs: {
      type: Array,
      required: true
    },
    pagination: {
      type: Boolean,
      default: true
    },
    pageSize: {
      type: Number,
      default: 10
    },
    selectable: {
      type: Boolean,
      default: false
    },
    showToolbar: {
      type: Boolean,
      default: true
    },
    toolbarActions: {
      type: Array,
      default: () => []
    },
    noDataMessage: {
      type: String,
      default: 'No hay datos para mostrar'
    }
  },
  emits: ['selection-changed', 'page-changed'],
  data() {
    return {
      searchQuery: '',
      filteredData: [],
      currentPage: 1,
      selectedRows: [],
      sortField: null,
      sortOrder: null
    }
  },
  computed: {
    columns() {
      return this.columnDefs.map(col => ({
        ...col,
        sortable: col.sortable !== false
      }))
    },
    paginatedData() {
      if (!this.pagination) return this.filteredData
      
      const start = (this.currentPage - 1) * this.pageSize
      const end = start + this.pageSize
      return this.filteredData.slice(start, end)
    },
    totalPages() {
      return Math.ceil(this.filteredData.length / this.pageSize)
    },
    visiblePages() {
      const pages = []
      const start = Math.max(1, this.currentPage - 2)
      const end = Math.min(this.totalPages, this.currentPage + 2)
      
      for (let i = start; i <= end; i++) {
        pages.push(i)
      }
      
      return pages
    },
    startRecord() {
      return (this.currentPage - 1) * this.pageSize + 1
    },
    endRecord() {
      return Math.min(this.currentPage * this.pageSize, this.filteredData.length)
    },
    allSelected() {
      return this.filteredData.length > 0 && this.selectedRows.length === this.filteredData.length
    }
  },
  watch: {
    rowData: {
      immediate: true,
      handler() {
        this.filteredData = [...this.rowData]
        this.currentPage = 1
        this.selectedRows = []
      }
    }
  },
  methods: {
    filterData() {
      if (!this.searchQuery) {
        this.filteredData = [...this.rowData]
      } else {
        this.filteredData = this.rowData.filter(row => {
          return this.columns.some(col => {
            const value = this.getNestedValue(row, col.field)
            return value && value.toString().toLowerCase().includes(this.searchQuery.toLowerCase())
          })
        })
      }
      this.currentPage = 1
    },
    sortBy(field) {
      if (this.sortField === field) {
        this.sortOrder = this.sortOrder === 'asc' ? 'desc' : 'asc'
      } else {
        this.sortField = field
        this.sortOrder = 'asc'
      }

      this.filteredData.sort((a, b) => {
        const aVal = this.getNestedValue(a, field)
        const bVal = this.getNestedValue(b, field)

        if (aVal < bVal) return this.sortOrder === 'asc' ? -1 : 1
        if (aVal > bVal) return this.sortOrder === 'asc' ? 1 : -1
        return 0
      })
    },
    goToPage(page) {
      if (page >= 1 && page <= this.totalPages) {
        this.currentPage = page
        this.$emit('page-changed', page)
      }
    },
    toggleRowSelection(id) {
      const index = this.selectedRows.indexOf(id)
      if (index > -1) {
        this.selectedRows.splice(index, 1)
      } else {
        this.selectedRows.push(id)
      }
      this.$emit('selection-changed', this.selectedRows)
    },
    toggleSelectAll() {
      if (this.allSelected) {
        this.selectedRows = []
      } else {
        this.selectedRows = this.filteredData.map(row => row.id)
      }
      this.$emit('selection-changed', this.selectedRows)
    },
    getNestedValue(obj, path) {
      return path.split('.').reduce((current, key) => current && current[key], obj)
    },
    formatDate(date) {
      if (!date) return ''
      return new Date(date).toLocaleDateString('es-MX')
    },
    formatCurrency(amount) {
      if (!amount) return '$0.00'
      return new Intl.NumberFormat('es-MX', {
        style: 'currency',
        currency: 'MXN'
      }).format(amount)
    },
    getBadgeClass(status) {
      const statusClasses = {
        'activo': 'badge bg-success',
        'inactivo': 'badge bg-secondary',
        'pendiente': 'badge bg-warning text-dark',
        'cancelado': 'badge bg-danger',
        'aprobado': 'badge bg-primary'
      }
      return statusClasses[status?.toLowerCase()] || 'badge bg-secondary'
    }
  }
}
</script>

<style scoped>
.grid-component {
  border: 1px solid #dee2e6;
  border-radius: 8px;
  overflow: hidden;
  background: white;
}

.grid-toolbar {
  padding: 1rem;
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
}

.table-responsive {
  max-height: 600px;
  overflow-y: auto;
}

.table {
  margin-bottom: 0;
  font-size: 0.9rem;
}

.table th {
  background-color: #343a40;
  color: white;
  font-weight: 600;
  border-color: #454d55;
  position: sticky;
  top: 0;
  z-index: 10;
}

.table th.sortable {
  cursor: pointer;
  user-select: none;
}

.table th.sortable:hover {
  background-color: #495057;
}

.sort-indicators {
  margin-left: 0.5rem;
  font-size: 0.8rem;
  opacity: 0.6;
}

.table tbody tr:hover {
  background-color: #f8f9fa;
}

.table-active {
  background-color: #e3f2fd !important;
}

.btn-group-sm > .btn {
  padding: 0.2rem 0.4rem;
  font-size: 0.8rem;
}

.pagination-sm .page-link {
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
}

.form-check-input {
  margin: 0;
}

.badge {
  font-size: 0.75rem;
}
</style>