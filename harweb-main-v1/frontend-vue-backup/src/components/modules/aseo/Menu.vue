<template>
  <div class="menu-page">
    <nav aria-label="breadcrumb" v-if="breadcrumb.length">
      <ol class="breadcrumb">
        <li v-for="(item, idx) in breadcrumb" :key="idx" class="breadcrumb-item" :class="{active: idx === breadcrumb.length-1}">
          <span v-if="idx !== breadcrumb.length-1">{{ item }}</span>
          <span v-else>{{ item }}</span>
        </li>
      </ol>
    </nav>
    <h1>Catálogo de Unidades de Recolección</h1>
    <div class="mb-3">
      <label for="ejercicio">Ejercicio:</label>
      <select v-model="ejercicio" id="ejercicio" class="form-control" @change="fetchUnidades">
        <option v-for="e in ejercicios" :key="e" :value="e">{{ e }}</option>
      </select>
    </div>
    <button class="btn btn-primary mb-2" @click="showCreate = true">Agregar Unidad</button>
    <table class="table table-bordered table-sm">
      <thead>
        <tr>
          <th>Clave</th>
          <th>Descripción</th>
          <th>Costo Unidad</th>
          <th>Costo Excedente</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="unidad in unidades" :key="unidad.id">
          <td>{{ unidad.clave }}</td>
          <td>{{ unidad.descripcion }}</td>
          <td>{{ unidad.costo_unidad }}</td>
          <td>{{ unidad.costo_exed }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="editUnidad(unidad)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteUnidad(unidad)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <!-- Modal Crear/Editar -->
    <div v-if="showCreate || showEdit" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ showCreate ? 'Agregar Unidad' : 'Editar Unidad' }}</h3>
          <form @submit.prevent="showCreate ? createUnidad() : updateUnidad()">
            <div class="form-group">
              <label>Clave</label>
              <input v-model="form.clave" class="form-control" :readonly="showEdit" required />
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input v-model="form.descripcion" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Costo Unidad</label>
              <input v-model.number="form.costo_unidad" type="number" step="0.01" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Costo Excedente</label>
              <input v-model.number="form.costo_exed" type="number" step="0.01" class="form-control" required />
            </div>
            <div class="form-group">
              <button class="btn btn-success" type="submit">Guardar</button>
              <button class="btn btn-secondary" type="button" @click="closeModal">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'CatalogoUnidadesPage',
  data() {
    return {
      breadcrumb: ['Catálogos', 'Unidades de Recolección'],
      ejercicios: [],
      ejercicio: '',
      unidades: [],
      showCreate: false,
      showEdit: false,
      form: {
        id: null,
        clave: '',
        descripcion: '',
        costo_unidad: 0,
        costo_exed: 0
      },
      error: ''
    };
  },
  mounted() {
    this.fetchEjercicios();
  },
  methods: {
    async fetchEjercicios() {
      // Simulación: en real, llamar API para ejercicios
      this.ejercicios = [2022, 2023, 2024];
      this.ejercicio = this.ejercicios[this.ejercicios.length-1];
      await this.fetchUnidades();
    },
    async fetchUnidades() {
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'catalog.list.unidades',
              params: { ejercicio: this.ejercicio }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.error) throw new Error(data.eResponse.error);
        this.unidades = data.eResponse.result;
      } catch (e) {
        this.error = e.message;
      }
    },
    closeModal() {
      this.showCreate = false;
      this.showEdit = false;
      this.form = { id: null, clave: '', descripcion: '', costo_unidad: 0, costo_exed: 0 };
    },
    editUnidad(unidad) {
      this.form = { ...unidad };
      this.showEdit = true;
    },
    async createUnidad() {
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'catalog.create.unidad',
              params: {
                ejercicio: this.ejercicio,
                clave: this.form.clave,
                descripcion: this.form.descripcion,
                costo_unidad: this.form.costo_unidad,
                costo_exed: this.form.costo_exed
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.error) throw new Error(data.eResponse.error);
        this.closeModal();
        await this.fetchUnidades();
      } catch (e) {
        this.error = e.message;
      }
    },
    async updateUnidad() {
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'catalog.update.unidad',
              params: {
                id: this.form.id,
                descripcion: this.form.descripcion,
                costo_unidad: this.form.costo_unidad,
                costo_exed: this.form.costo_exed
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.error) throw new Error(data.eResponse.error);
        this.closeModal();
        await this.fetchUnidades();
      } catch (e) {
        this.error = e.message;
      }
    },
    async deleteUnidad(unidad) {
      if (!confirm('¿Está seguro de eliminar la unidad?')) return;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'catalog.delete.unidad',
              params: { id: unidad.id }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.error) throw new Error(data.eResponse.error);
        await this.fetchUnidades();
      } catch (e) {
        this.error = e.message;
      }
    }
  }
};
</script>

<style scoped>
.menu-page {
  max-width: 900px;
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
  width: 400px;
  background: #fff;
  border-radius: 8px;
  padding: 2rem;
}
</style>
