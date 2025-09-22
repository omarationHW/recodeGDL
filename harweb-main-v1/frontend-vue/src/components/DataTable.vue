<template>
  <div class="data-table">
    <div class="table-responsive">
      <table class="table table-striped table-hover">
        <thead class="table-dark">
          <tr>
            <th v-for="column in columns" :key="column.key" :class="column.class">
              {{ column.label }}
            </th>
            <th v-if="actions.length > 0" class="text-center">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in data" :key="item.id || Math.random()">
            <td v-for="column in columns" :key="column.key" :class="column.class">
              <span v-if="column.type === 'text'">{{ item[column.key] }}</span>
              <span v-else-if="column.type === 'date'">{{ formatDate(item[column.key]) }}</span>
              <span v-else-if="column.type === 'currency'">{{ formatCurrency(item[column.key]) }}</span>
              <span v-else-if="column.type === 'status'">
                <span :class="getStatusClass(item[column.key])">{{ item[column.key] }}</span>
              </span>
              <span v-else>{{ item[column.key] }}</span>
            </td>
            <td v-if="actions.length > 0" class="text-center">
              <div class="btn-group btn-group-sm">
                <button
                  v-for="action in actions"
                  :key="action.name"
                  :class="action.class || 'btn btn-outline-primary'"
                  @click="$emit(action.event, item)"
                  :title="action.title"
                >
                  <i v-if="action.icon" :class="action.icon"></i>
                  {{ action.label }}
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <div v-if="data.length === 0" class="text-center py-4">
      <p class="text-muted">No hay datos disponibles</p>
    </div>
    
    <!-- Paginación si es necesaria -->
    <nav v-if="pagination && totalPages > 1" class="d-flex justify-content-center">
      <ul class="pagination">
        <li class="page-item" :class="{ disabled: currentPage === 1 }">
          <button class="page-link" @click="$emit('page-change', currentPage - 1)">Anterior</button>
        </li>
        <li 
          v-for="page in visiblePages" 
          :key="page" 
          class="page-item" 
          :class="{ active: page === currentPage }"
        >
          <button class="page-link" @click="$emit('page-change', page)">{{ page }}</button>
        </li>
        <li class="page-item" :class="{ disabled: currentPage === totalPages }">
          <button class="page-link" @click="$emit('page-change', currentPage + 1)">Siguiente</button>
        </li>
      </ul>
    </nav>
  </div>
</template>

<script>
export default {
  name: 'DataTable',
  props: {
    data: {
      type: Array,
      default: () => []
    },
    columns: {
      type: Array,
      required: true
    },
    actions: {
      type: Array,
      default: () => []
    },
    pagination: {
      type: Boolean,
      default: false
    },
    currentPage: {
      type: Number,
      default: 1
    },
    totalPages: {
      type: Number,
      default: 1
    }
  },
  emits: ['page-change'],
  computed: {
    visiblePages() {
      const pages = []
      const start = Math.max(1, this.currentPage - 2)
      const end = Math.min(this.totalPages, this.currentPage + 2)
      
      for (let i = start; i <= end; i++) {
        pages.push(i)
      }
      
      return pages
    }
  },
  methods: {
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
    getStatusClass(status) {
      const statusClasses = {
        'activo': 'badge bg-success',
        'inactivo': 'badge bg-secondary',
        'pendiente': 'badge bg-warning',
        'cancelado': 'badge bg-danger'
      }
      return statusClasses[status?.toLowerCase()] || 'badge bg-secondary'
    }
  }
}
</script>

<style scoped>
.data-table {
  margin: 20px 0;
}

.table-responsive {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.table {
  margin-bottom: 0;
}

.table thead th {
  border-bottom: 2px solid #dee2e6;
  font-weight: 600;
}

.btn-group-sm > .btn {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.pagination {
  margin-top: 20px;
}

.page-link {
  color: #007bff;
  border-color: #dee2e6;
}

.page-item.active .page-link {
  background-color: #007bff;
  border-color: #007bff;
}

.page-item.disabled .page-link {
  color: #6c757d;
  pointer-events: none;
}
</style>