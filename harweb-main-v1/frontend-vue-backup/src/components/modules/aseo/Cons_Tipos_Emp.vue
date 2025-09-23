<template>
  <div class="cons-tipos-emp-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Tipos de Empresa</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-body d-flex align-items-center">
        <div class="me-3">
          <label for="orderBy" class="form-label">Clasificación por:</label>
          <select v-model="orderBy" @change="fetchData" class="form-select" id="orderBy">
            <option value="ctrol_emp">Control</option>
            <option value="tipo_empresa">Tipo</option>
            <option value="descripcion">Descripción</option>
          </select>
        </div>
        <button class="btn btn-success ms-3" @click="exportExcel"><i class="bi bi-file-earmark-excel"></i> Exportar Excel</button>
        <button class="btn btn-primary ms-3" @click="showCreateModal = true">Nuevo Tipo</button>
      </div>
    </div>
    <div class="card">
      <div class="card-body p-0">
        <table class="table table-striped table-hover mb-0">
          <thead>
            <tr>
              <th>Control</th>
              <th>Tipo</th>
              <th>Descripción</th>
              <th style="width:120px">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.ctrol_emp">
              <td>{{ row.ctrol_emp }}</td>
              <td>{{ row.tipo_empresa }}</td>
              <td>{{ row.descripcion }}</td>
              <td>
                <button class="btn btn-sm btn-warning me-1" @click="editRow(row)"><i class="bi bi-pencil"></i></button>
                <button class="btn btn-sm btn-danger" @click="deleteRow(row)"><i class="bi bi-trash"></i></button>
              </td>
            </tr>
            <tr v-if="rows.length === 0">
              <td colspan="4" class="text-center">No hay registros</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <div v-if="showCreateModal || showEditModal" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ showEditModal ? 'Editar Tipo de Empresa' : 'Nuevo Tipo de Empresa' }}</h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="showEditModal ? updateRow() : createRow()">
              <div class="mb-3">
                <label class="form-label">Tipo</label>
                <input v-model="form.tipo_empresa" maxlength="1" required class="form-control" />
              </div>
              <div class="mb-3">
                <label class="form-label">Descripción</label>
                <input v-model="form.descripcion" maxlength="80" required class="form-control" />
              </div>
              <div class="text-end">
                <button type="button" class="btn btn-secondary me-2" @click="closeModal">Cancelar</button>
                <button type="submit" class="btn btn-primary">{{ showEditModal ? 'Actualizar' : 'Crear' }}</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    <!-- Modal backdrop -->
    <div v-if="showCreateModal || showEditModal" class="modal-backdrop fade show"></div>
  </div>
</template>

<script>
export default {
  name: 'ConsTiposEmpPage',
  data() {
    return {
      rows: [],
      orderBy: 'ctrol_emp',
      showCreateModal: false,
      showEditModal: false,
      form: {
        ctrol_emp: null,
        tipo_empresa: '',
        descripcion: ''
      },
      editId: null
    };
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    async fetchData() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'list',
          params: { order: this.orderBy },
          resource: 'ConsTiposEmp'
        })
      });
      const data = await res.json();
      if (data.success) {
        this.rows = data.data;
      } else {
        this.rows = [];
      }
    },
    closeModal() {
      this.showCreateModal = false;
      this.showEditModal = false;
      this.form = { ctrol_emp: null, tipo_empresa: '', descripcion: '' };
      this.editId = null;
    },
    async createRow() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'create',
          params: {
            tipo_empresa: this.form.tipo_empresa,
            descripcion: this.form.descripcion
          },
          resource: 'ConsTiposEmp'
        })
      });
      const data = await res.json();
      if (data.success) {
        this.closeModal();
        this.fetchData();
      } else {
        alert(data.message || 'Error al crear');
      }
    },
    editRow(row) {
      this.form = { ...row };
      this.editId = row.ctrol_emp;
      this.showEditModal = true;
    },
    async updateRow() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'update',
          params: {
            ctrol_emp: this.form.ctrol_emp,
            tipo_empresa: this.form.tipo_empresa,
            descripcion: this.form.descripcion
          },
          resource: 'ConsTiposEmp'
        })
      });
      const data = await res.json();
      if (data.success) {
        this.closeModal();
        this.fetchData();
      } else {
        alert(data.message || 'Error al actualizar');
      }
    },
    async deleteRow(row) {
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'delete',
          params: { ctrol_emp: row.ctrol_emp },
          resource: 'ConsTiposEmp'
        })
      });
      const data = await res.json();
      if (data.success) {
        this.fetchData();
      } else {
        alert(data.message || 'Error al eliminar');
      }
    },
    async exportExcel() {
      // Simple CSV export for demo
      let csv = 'Control,Tipo,Descripción\n';
      this.rows.forEach(r => {
        csv += `${r.ctrol_emp},${r.tipo_empresa},"${r.descripcion.replace(/"/g, '""')}"\n`;
      });
      const blob = new Blob([csv], { type: 'text/csv' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'tipos_empresas.csv';
      a.click();
      URL.revokeObjectURL(url);
    }
  }
}
</script>

<style scoped>
.cons-tipos-emp-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.modal-backdrop {
  z-index: 1040;
}
.modal {
  z-index: 1050;
}
</style>
