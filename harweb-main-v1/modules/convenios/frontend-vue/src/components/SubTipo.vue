<template>
  <div class="subtipo-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">SubTipos de Convenios</li>
      </ol>
    </nav>
    <h1>SubTipos de Convenios</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showCreate = true">Agregar SubTipo</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Tipo</th>
          <th>SubTipo</th>
          <th>Descripción</th>
          <th>Cuenta Ingreso</th>
          <th>Usuario</th>
          <th>Fecha Actual</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in subtipos" :key="row.tipo + '-' + row.subtipo">
          <td>{{ row.tipo }}</td>
          <td>{{ row.subtipo }}</td>
          <td>{{ row.desc_subtipo }}</td>
          <td>{{ row.cuenta_ingreso }}</td>
          <td>{{ row.usuario }}</td>
          <td>{{ row.fecha_actual }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="editRow(row)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteRow(row)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Crear/Editar Modal -->
    <div v-if="showCreate || showEdit" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ showEdit ? 'Editar SubTipo' : 'Agregar SubTipo' }}</h3>
          <form @submit.prevent="showEdit ? updateSubtipo() : createSubtipo()">
            <div class="form-group">
              <label>Tipo</label>
              <input v-model.number="form.tipo" type="number" class="form-control" :readonly="showEdit" required />
            </div>
            <div class="form-group">
              <label>SubTipo</label>
              <input v-model.number="form.subtipo" type="number" class="form-control" :readonly="showEdit" required />
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input v-model="form.desc_subtipo" type="text" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Cuenta Ingreso</label>
              <input v-model.number="form.cuenta_ingreso" type="number" class="form-control" required />
            </div>
            <div class="form-group">
              <label>ID Usuario</label>
              <input v-model.number="form.id_usuario" type="number" class="form-control" required />
            </div>
            <div class="modal-footer">
              <button class="btn btn-secondary" @click="closeModal">Cancelar</button>
              <button class="btn btn-primary" type="submit">Guardar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Confirmación de eliminación -->
    <div v-if="showDelete" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>¿Eliminar SubTipo?</h3>
          <p>¿Está seguro de eliminar el SubTipo {{ form.tipo }}-{{ form.subtipo }}?</p>
          <div class="modal-footer">
            <button class="btn btn-secondary" @click="showDelete = false">Cancelar</button>
            <button class="btn btn-danger" @click="confirmDelete">Eliminar</button>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
export default {
  name: 'SubTipoPage',
  data() {
    return {
      subtipos: [],
      showCreate: false,
      showEdit: false,
      showDelete: false,
      form: {
        tipo: '',
        subtipo: '',
        desc_subtipo: '',
        cuenta_ingreso: '',
        id_usuario: ''
      },
      deleteTarget: null
    }
  },
  mounted() {
    this.fetchSubtipos();
  },
  methods: {
    async fetchSubtipos() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'list_subtipos' })
      });
      const json = await res.json();
      if (json.success) {
        this.subtipos = json.data;
      }
    },
    closeModal() {
      this.showCreate = false;
      this.showEdit = false;
      this.showDelete = false;
      this.form = { tipo: '', subtipo: '', desc_subtipo: '', cuenta_ingreso: '', id_usuario: '' };
    },
    async createSubtipo() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'create_subtipo', params: this.form })
      });
      const json = await res.json();
      if (json.success) {
        this.fetchSubtipos();
        this.closeModal();
      } else {
        alert(json.message || 'Error al crear');
      }
    },
    editRow(row) {
      this.form = { ...row };
      this.showEdit = true;
    },
    async updateSubtipo() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'update_subtipo', params: this.form })
      });
      const json = await res.json();
      if (json.success) {
        this.fetchSubtipos();
        this.closeModal();
      } else {
        alert(json.message || 'Error al actualizar');
      }
    },
    deleteRow(row) {
      this.form = { ...row };
      this.showDelete = true;
    },
    async confirmDelete() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'delete_subtipo', params: this.form })
      });
      const json = await res.json();
      if (json.success) {
        this.fetchSubtipos();
        this.closeModal();
      } else {
        alert(json.message || 'Error al eliminar');
      }
    }
  }
}
</script>

<style scoped>
.subtipo-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
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
  width: 100%;
  max-width: 500px;
}
.modal-container {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.33);
}
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 1rem;
}
</style>
