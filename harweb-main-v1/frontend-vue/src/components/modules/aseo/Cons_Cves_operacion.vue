<template>
  <div class="cons-cves-operacion-page">
    <div class="breadcrumb">
      <span>Catálogos</span> &gt; <span>Claves de Operación</span>
    </div>
    <div class="panel panel-top">
      <div class="row align-items-center">
        <div class="col-md-6">
          <label>Clasificación por:</label>
          <select v-model="order" @change="fetchList" class="form-select d-inline-block w-auto ms-2">
            <option value="ctrol_operacion">Control</option>
            <option value="cve_operacion">Clave</option>
            <option value="descripcion">Descripción</option>
          </select>
        </div>
        <div class="col-md-6 text-end">
          <button class="btn btn-success me-2" @click="exportExcel">Exportar Excel</button>
          <button class="btn btn-primary me-2" @click="showCreate">Nuevo</button>
          <button class="btn btn-secondary" @click="goBack">Salir</button>
        </div>
      </div>
    </div>
    <div class="panel panel-body mt-3">
      <table class="table table-bordered table-striped">
        <thead>
          <tr>
            <th>Control</th>
            <th>Clave</th>
            <th>Descripción</th>
            <th style="width:120px">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.ctrol_operacion">
            <td>{{ row.ctrol_operacion }}</td>
            <td>{{ row.cve_operacion }}</td>
            <td>{{ row.descripcion }}</td>
            <td>
              <button class="btn btn-sm btn-warning me-1" @click="showEdit(row)">Editar</button>
              <button class="btn btn-sm btn-danger" @click="confirmDelete(row)">Eliminar</button>
            </td>
          </tr>
          <tr v-if="rows.length === 0">
            <td colspan="4" class="text-center">No hay registros</td>
          </tr>
        </tbody>
      </table>
    </div>
    <!-- Modal Create/Edit -->
    <div v-if="modalVisible" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ modalMode === 'create' ? 'Nueva Clave de Operación' : 'Editar Clave de Operación' }}</h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="modalMode === 'create' ? createRow() : updateRow()">
              <div class="mb-3" v-if="modalMode === 'edit'">
                <label>Control</label>
                <input type="text" class="form-control" v-model="form.ctrol_operacion" readonly />
              </div>
              <div class="mb-3">
                <label>Clave</label>
                <input type="text" class="form-control" v-model="form.cve_operacion" :readonly="modalMode==='edit'" maxlength="1" required />
              </div>
              <div class="mb-3">
                <label>Descripción</label>
                <input type="text" class="form-control" v-model="form.descripcion" maxlength="80" required />
              </div>
              <div class="text-end">
                <button type="submit" class="btn btn-primary">Guardar</button>
                <button type="button" class="btn btn-secondary ms-2" @click="closeModal">Cancelar</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    <!-- Modal Delete -->
    <div v-if="deleteVisible" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Eliminar Clave</h5>
            <button type="button" class="btn-close" @click="deleteVisible=false"></button>
          </div>
          <div class="modal-body">
            <p>¿Está seguro que desea eliminar la clave <b>{{ deleteRow.cve_operacion }}</b>?</p>
            <div class="text-end">
              <button class="btn btn-danger" @click="deleteRowConfirm">Eliminar</button>
              <button class="btn btn-secondary ms-2" @click="deleteVisible=false">Cancelar</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsCvesOperacionPage',
  data() {
    return {
      rows: [],
      order: 'ctrol_operacion',
      modalVisible: false,
      modalMode: 'create',
      form: {
        ctrol_operacion: '',
        cve_operacion: '',
        descripcion: ''
      },
      deleteVisible: false,
      deleteRow: {}
    };
  },
  mounted() {
    this.fetchList();
  },
  methods: {
    fetchList() {
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'list',
          data: { order: this.order }
        }
      }).then(resp => {
        this.rows = resp.data.eResponse.data || [];
      });
    },
    showCreate() {
      this.modalMode = 'create';
      this.form = { ctrol_operacion: '', cve_operacion: '', descripcion: '' };
      this.modalVisible = true;
    },
    showEdit(row) {
      this.modalMode = 'edit';
      this.form = { ...row };
      this.modalVisible = true;
    },
    closeModal() {
      this.modalVisible = false;
    },
    createRow() {
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'create',
          data: {
            cve_operacion: this.form.cve_operacion,
            descripcion: this.form.descripcion
          }
        }
      }).then(resp => {
        if (resp.data.eResponse.status === 'success') {
          this.modalVisible = false;
          this.fetchList();
        } else {
          alert(resp.data.eResponse.message);
        }
      });
    },
    updateRow() {
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'update',
          data: {
            ctrol_operacion: this.form.ctrol_operacion,
            descripcion: this.form.descripcion
          }
        }
      }).then(resp => {
        if (resp.data.eResponse.status === 'success') {
          this.modalVisible = false;
          this.fetchList();
        } else {
          alert(resp.data.eResponse.message);
        }
      });
    },
    confirmDelete(row) {
      this.deleteRow = row;
      this.deleteVisible = true;
    },
    deleteRowConfirm() {
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'delete',
          data: {
            ctrol_operacion: this.deleteRow.ctrol_operacion
          }
        }
      }).then(resp => {
        if (resp.data.eResponse.status === 'success') {
          this.deleteVisible = false;
          this.fetchList();
        } else {
          alert(resp.data.eResponse.message);
        }
      });
    },
    exportExcel() {
      // Implementar exportación a Excel si es necesario
      alert('Exportación a Excel no implementada en esta demo.');
    },
    goBack() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.cons-cves-operacion-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 24px;
}
.panel {
  background: #f8f9fa;
  border-radius: 6px;
  padding: 16px;
}
.breadcrumb {
  font-size: 14px;
  margin-bottom: 12px;
  color: #888;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-dialog {
  background: #fff;
  border-radius: 8px;
  min-width: 350px;
  max-width: 400px;
  box-shadow: 0 2px 16px rgba(0,0,0,0.2);
}
</style>
