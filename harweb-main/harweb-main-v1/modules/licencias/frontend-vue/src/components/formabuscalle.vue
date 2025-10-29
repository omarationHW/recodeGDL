<template>
  <div class="formabuscalle-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Calles</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header text-center">
        <h5>BUSQUEDA DE CALLES</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent>
          <div class="form-group row align-items-center">
            <label for="calle" class="col-sm-2 col-form-label">Nombre de la calle</label>
            <div class="col-sm-8">
              <input
                id="calle"
                v-model="filtro"
                @input="buscarCalles"
                type="text"
                class="form-control text-uppercase"
                placeholder="Ingrese el nombre de la calle"
                autocomplete="off"
                maxlength="40"
              />
            </div>
            <div class="col-sm-2">
              <span v-if="selectedCveCalle" class="badge badge-info">ID: {{ selectedCveCalle }}</span>
            </div>
          </div>
        </form>
        <div class="mt-4">
          <table class="table table-bordered table-hover">
            <thead class="thead-light">
              <tr>
                <th style="width: 90%">CALLE</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(calle, idx) in calles"
                :key="calle.cvecalle"
                :class="{ 'table-active': selectedIndex === idx }"
                @click="selectCalle(idx)"
                style="cursor:pointer"
              >
                <td>{{ calle.calle }}</td>
              </tr>
              <tr v-if="calles.length === 0">
                <td class="text-center">No se encontraron calles</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="card-footer text-center">
        <button class="btn btn-primary" @click="aceptar">Aceptar</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Formabuscalle',
  data() {
    return {
      filtro: '',
      calles: [],
      selectedIndex: null,
      selectedCveCalle: null
    };
  },
  mounted() {
    this.listarCalles();
    this.$nextTick(() => {
      const input = document.getElementById('calle');
      if (input) input.focus();
    });
  },
  methods: {
    async buscarCalles() {
      // Llamar API para buscar calles por filtro
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            action: 'buscar_calles',
            params: { filtro: this.filtro }
          })
        });
        const data = await resp.json();
        if (data.success) {
          this.calles = data.data;
          this.selectedIndex = null;
          this.selectedCveCalle = null;
        }
      } catch (e) {
        alert('Error al buscar calles: ' + e);
      }
    },
    async listarCalles() {
      // Llamar API para listar todas las calles
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            action: 'listar_calles',
            params: {}
          })
        });
        const data = await resp.json();
        if (data.success) {
          this.calles = data.data;
          this.selectedIndex = null;
          this.selectedCveCalle = null;
        }
      } catch (e) {
        alert('Error al cargar calles: ' + e);
      }
    },
    selectCalle(idx) {
      this.selectedIndex = idx;
      this.selectedCveCalle = this.calles[idx].cvecalle;
    },
    aceptar() {
      // Simula el cierre del formulario y muestra el ID seleccionado
      if (this.selectedCveCalle) {
        alert('ID de calle seleccionada: ' + this.selectedCveCalle);
      } else {
        alert('No se ha seleccionado ninguna calle.');
      }
    }
  }
};
</script>

<style scoped>
.formabuscalle-page {
  max-width: 700px;
  margin: 0 auto;
  padding-top: 30px;
}
.table-hover tbody tr:hover {
  background-color: #f5f5f5;
}
.table-active {
  background-color: #d1ecf1 !important;
}
.text-uppercase {
  text-transform: uppercase;
}
</style>
