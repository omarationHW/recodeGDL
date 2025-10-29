<template>
  <div class="page-cves-operacion">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo Claves de Operación</li>
      </ol>
    </nav>
    <h1>Catálogo de Claves de Operación</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showInsertForm = true">Agregar Clave</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>#</th>
          <th>Clave</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(item, idx) in cves" :key="item.ctrol_operacion">
          <td>{{ item.ctrol_operacion }}</td>
          <td>{{ item.cve_operacion }}</td>
          <td>{{ item.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="editItem(item)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteItem(item)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="cves.length === 0">
          <td colspan="4" class="text-center">No hay registros</td>
        </tr>
      </tbody>
    </table>

    <!-- Insert Modal -->
    <div v-if="showInsertForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>Agregar Clave de Operación</h3>
          <form @submit.prevent="insert">
            <div class="form-group">
              <label>Clave</label>
              <input v-model="form.cve_operacion" maxlength="1" required class="form-control" />
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input v-model="form.descripcion" maxlength="80" required class="form-control" />
            </div>
            <div class="modal-footer">
              <button class="btn btn-primary" type="submit">Guardar</button>
              <button class="btn btn-secondary" @click="showInsertForm = false">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Edit Modal -->
    <div v-if="showEditForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>Editar Clave de Operación</h3>
          <form @submit.prevent="update">
            <div class="form-group">
              <label>Clave</label>
              <input v-model="form.cve_operacion" maxlength="1" required class="form-control" />
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input v-model="form.descripcion" maxlength="80" required class="form-control" />
            </div>
            <div class="modal-footer">
              <button class="btn btn-primary" type="submit">Actualizar</button>
              <button class="btn btn-secondary" @click="showEditForm = false">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Mensaje -->
    <div v-if="message" class="alert" :class="{'alert-success': messageType==='success', 'alert-danger': messageType==='error'}">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'CvesOperacionPage',
  data() {
    return {
      cves: [],
      showInsertForm: false,
      showEditForm: false,
      form: {
        ctrol_operacion: null,
        cve_operacion: '',
        descripcion: ''
      },
      message: '',
      messageType: 'success',
      loading: false
    };
  },
  created() {
    this.fetchList();
  },
  methods: {
    async fetchList() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'list', data: {} }
        });
        this.cves = res.data.eResponse.data || [];
      } catch (e) {
        this.message = 'Error al cargar datos';
        this.messageType = 'error';
      } finally {
        this.loading = false;
      }
    },
    async insert() {
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'insert', data: {
            cve_operacion: this.form.cve_operacion,
            descripcion: this.form.descripcion
          } }
        });
        if (res.data.eResponse.success) {
          this.message = res.data.eResponse.message;
          this.messageType = 'success';
          this.showInsertForm = false;
          this.fetchList();
        } else {
          this.message = res.data.eResponse.message;
          this.messageType = 'error';
        }
      } catch (e) {
        this.message = 'Error al guardar';
        this.messageType = 'error';
      }
    },
    editItem(item) {
      this.form = { ...item };
      this.showEditForm = true;
    },
    async update() {
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'update', data: {
            ctrol_operacion: this.form.ctrol_operacion,
            cve_operacion: this.form.cve_operacion,
            descripcion: this.form.descripcion
          } }
        });
        if (res.data.eResponse.success) {
          this.message = res.data.eResponse.message;
          this.messageType = 'success';
          this.showEditForm = false;
          this.fetchList();
        } else {
          this.message = res.data.eResponse.message;
          this.messageType = 'error';
        }
      } catch (e) {
        this.message = 'Error al actualizar';
        this.messageType = 'error';
      }
    },
    async deleteItem(item) {
      if (!confirm('¿Está seguro de eliminar la clave?')) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'delete', data: { ctrol_operacion: item.ctrol_operacion } }
        });
        if (res.data.eResponse.success) {
          this.message = res.data.eResponse.message;
          this.messageType = 'success';
          this.fetchList();
        } else {
          this.message = res.data.eResponse.message;
          this.messageType = 'error';
        }
      } catch (e) {
        this.message = 'Error al eliminar';
        this.messageType = 'error';
      }
    }
  }
};
</script>

<style scoped>
.page-cves-operacion {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-wrapper {
  width: 400px;
}
.modal-container {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
.modal-footer {
  margin-top: 1rem;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}
</style>
